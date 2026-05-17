import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/pet_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pets_provider.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('/')) {
      final baseUrl = dotenv.env['API_BASE_URL']?.trim() ?? 'http://localhost:5001';
      return '$baseUrl$imagePath';
    }

    return imagePath;
  }

  Future<void> _showReviewDialog(BuildContext context, PetModel pet) async {
    final token = context.read<AuthProvider>().authToken;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add a review.')),
      );
      return;
    }

    final commentController = TextEditingController();
    double rating = 5;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Review Seller'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How was your experience buying ${pet.name} from ${pet.ownerName}?',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rating: ${rating.toStringAsFixed(0)} / 5',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: rating.toStringAsFixed(0),
                      onChanged: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Write your review',
                        hintText: 'Share your experience...',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (commentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Please write a comment.')),
                      );
                      return;
                    }
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted != true || !context.mounted) return;

    final success = await context.read<PetsProvider>().addReview(
          token: token,
          petId: pet.id,
          rating: rating.round(),
          comment: commentController.text.trim(),
        );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<PetsProvider>().errorMessage ?? 'Review failed.')),
      );
    }
  }

  bool _hasReviewed(PetModel pet, String? currentUserId) {
    if (currentUserId == null || currentUserId.isEmpty) {
      return false;
    }

    final reviews = pet.reviews ?? const [];
    return reviews.any((review) => review['buyerId']?.toString() == currentUserId);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().authToken;
      if (token != null && token.isNotEmpty) {
        context.read<PetsProvider>().loadMyOrders(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final petsProvider = context.watch<PetsProvider>();
    final orders = petsProvider.myOrders;
    final isLoading = petsProvider.isLoading;
    final errorMessage = petsProvider.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final token = context.read<AuthProvider>().authToken;
          if (token != null && token.isNotEmpty) {
            await context.read<PetsProvider>().loadMyOrders(token);
          }
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : (errorMessage != null && errorMessage.isNotEmpty)
                ? Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No orders yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final pet = orders[index];
                          return _buildOrderCard(pet);
                        },
                      ),
      ),
    );
  }

  Widget _buildOrderCard(PetModel pet) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final alreadyReviewed = _hasReviewed(pet, currentUserId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.push('/pet/${pet.id}', extra: pet);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: pet.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _getImageUrl(pet.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.pets,
                              size: 40,
                              color: Colors.blue,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.pets,
                        size: 40,
                        color: Colors.blue,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.category,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        Text(
                          pet.price.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (pet.deliveryStatus == 'completed'
                                    ? Colors.green
                                    : Colors.orange)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (pet.deliveryStatus == 'completed')
                                ? 'DELIVERED'
                                : 'PENDING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: pet.deliveryStatus == 'completed'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (alreadyReviewed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'REVIEWED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: alreadyReviewed
                          ? Text(
                              'You already reviewed this order',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () => _showReviewDialog(context, pet),
                              icon: const Icon(Icons.rate_review_outlined, size: 18),
                              label: const Text('Write Review'),
                            ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
