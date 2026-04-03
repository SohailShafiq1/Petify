import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/pet_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pets_provider.dart';

class MySalesScreen extends StatefulWidget {
  const MySalesScreen({super.key});

  @override
  State<MySalesScreen> createState() => _MySalesScreenState();
}

class _MySalesScreenState extends State<MySalesScreen> {
  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('/')) {
      final baseUrl = dotenv.env['API_BASE_URL']?.trim() ?? 'http://localhost:5001';
      return '$baseUrl$imagePath';
    }

    return imagePath;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().authToken;
      if (token != null && token.isNotEmpty) {
        context.read<PetsProvider>().loadMySales(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final petsProvider = context.watch<PetsProvider>();
    final sales = petsProvider.mySales;
    final isLoading = petsProvider.isLoading;
    final errorMessage = petsProvider.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sales'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final token = context.read<AuthProvider>().authToken;
          if (token != null && token.isNotEmpty) {
            await context.read<PetsProvider>().loadMySales(token);
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
                : sales.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No sales yet',
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
                        itemCount: sales.length,
                        itemBuilder: (context, index) {
                          final pet = sales[index];
                          return _buildSaleCard(context, pet, petsProvider);
                        },
                      ),
      ),
    );
  }

  Widget _buildSaleCard(BuildContext context, PetModel pet, PetsProvider petsProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.push('/pet/${pet.id}', extra: pet);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buyer Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(child: Text(pet.buyerName ?? 'Unknown')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(child: Text(pet.buyerContact ?? 'Unknown')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(child: Text(pet.buyerAddress ?? 'Unknown')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (pet.deliveryStatus == 'completed')
                      ? null
                      : () async {
                          final token = context.read<AuthProvider>().authToken;
                          if (token == null || token.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please log in again.')),
                            );
                            return;
                          }

                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Complete Delivery'),
                                content: const Text('Mark this delivery as completed?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmed != true) return;

                          final success = await petsProvider.completeDelivery(
                            token: token,
                            petId: pet.id,
                          );

                          if (!context.mounted) return;

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Delivery marked as completed.')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(petsProvider.errorMessage ?? 'Update failed.')),
                            );
                          }
                        },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark Delivery Completed'),
                ),
              ),
             ],
           ),
         ),
       ),
     );
   }
 }
