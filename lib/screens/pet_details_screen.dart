import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/pet_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pets_provider.dart';

class PetDetailsScreen extends StatelessWidget {
  final String petId;

  const PetDetailsScreen({
    super.key,
    required this.petId,
  });

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('/')) {
      final baseUrl = dotenv.env['API_BASE_URL']?.trim() ?? 'http://localhost:5001';
      return '$baseUrl$imagePath';
    }

    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    // In a real app, we'd get this from the provider
    // For now, we'll pass it through the extra parameter
    final pet = GoRouterState.of(context).extra as PetModel?;

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pet Details'),
        ),
        body: const Center(
          child: Text('Pet not found'),
        ),
      );
    }

    final authProvider = context.watch<AuthProvider>();
    final petsProvider = context.watch<PetsProvider>();
    final currentUserId = authProvider.currentUser?.id;
    final isOwner = currentUserId != null && currentUserId == pet.ownerId;
    final isFavorite = petsProvider.isFavorite(pet.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.blue.shade700,
            actions: [
              IconButton(
                onPressed: () async {
                  final token = authProvider.authToken;
                  if (token == null || token.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please log in to save favorites.')),
                    );
                    return;
                  }

                  final success = await petsProvider.toggleFavorite(
                    token: token,
                    pet: pet,
                  );

                  if (!context.mounted) return;

                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(petsProvider.errorMessage ?? 'Update failed.')),
                    );
                  }
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red.shade200 : Colors.white,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: pet.imagePath != null
                  ? (pet.imagePath!.startsWith('/'))
                      ? Image.network(
                          _getImageUrl(pet.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.pets,
                                size: 100,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                      : Image.file(
                          File(pet.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.pets,
                                size: 100,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                  : Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.pets,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '\$${pet.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.category,
                          label: 'Category',
                          value: pet.category,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.cake,
                          label: 'Age',
                          value: '${pet.age} months',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pet.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Owner Details
                  Text(
                    'Owner Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.grey.shade600),
                            const SizedBox(width: 12),
                            Text(
                              pet.ownerName,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.grey.shade600),
                            const SizedBox(width: 12),
                            Text(
                              pet.ownerContact,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Posted Date
                  Text(
                    'Posted ${DateFormat('MMM dd, yyyy').format(pet.createdAt)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  if (isOwner && !pet.isAvailable)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buyer Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.grey.shade600),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        pet.buyerName ?? 'Unknown',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.phone, color: Colors.grey.shade600),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        pet.buyerContact ?? 'Unknown',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on, color: Colors.grey.shade600),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        pet.buyerAddress ?? 'Unknown',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                                if (pet.soldAt != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sold ${DateFormat('MMM dd, yyyy').format(pet.soldAt!)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push('/chat/${pet.id}', extra: pet);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.blue.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.chat_bubble_outline, color: Colors.blue.shade700),
                  label: Text(
                    'Chat',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (!pet.isAvailable || isOwner || petsProvider.isLoading)
                      ? null
                      : () async {
                          final token = authProvider.authToken;
                          if (token == null || token.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please log in to buy this pet.')),
                            );
                            return;
                          }

                          final nameController = TextEditingController();
                          final contactController = TextEditingController();
                          final addressController = TextEditingController();
                          final formKey = GlobalKey<FormState>();

                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Buy This Pet (COD)'),
                                content: Form(
                                  key: formKey,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Full name',
                                          ),
                                          textInputAction: TextInputAction.next,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Name is required';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: contactController,
                                          decoration: const InputDecoration(
                                            labelText: 'Contact number',
                                          ),
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.next,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Contact number is required';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: addressController,
                                          decoration: const InputDecoration(
                                            labelText: 'Delivery address',
                                          ),
                                          keyboardType: TextInputType.streetAddress,
                                          textInputAction: TextInputAction.done,
                                          maxLines: 2,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Address is required';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Payment method: Cash on Delivery (COD).',
                                          style: TextStyle(color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (formKey.currentState?.validate() != true) return;
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmed != true) return;

                          final success = await petsProvider.buyPet(
                            token: token,
                            petId: pet.id,
                            buyerName: nameController.text.trim(),
                            buyerContact: contactController.text.trim(),
                            buyerAddress: addressController.text.trim(),
                          );

                          if (!context.mounted) return;

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Purchase successful. Pet marked as sold.')),
                            );
                            context.pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(petsProvider.errorMessage ?? 'Purchase failed.')),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(
                    pet.isAvailable
                        ? (isOwner ? 'Your Listing' : 'Buy This Pet')
                        : 'Sold',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
