import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/pet_model.dart';
import '../providers/pets_provider.dart';
import '../services/pet_api_service.dart';
import '../widgets/pet_card.dart';

class OwnerPetsScreen extends StatefulWidget {
  final String ownerId;
  final String? ownerName;
  final String? ownerContact;

  const OwnerPetsScreen({
    super.key,
    required this.ownerId,
    this.ownerName,
    this.ownerContact,
  });

  @override
  State<OwnerPetsScreen> createState() => _OwnerPetsScreenState();
}

class _OwnerPetsScreenState extends State<OwnerPetsScreen> {
  final PetApiService _petApiService = PetApiService();
  Map<String, dynamic>? _ownerSummary;
  bool _isLoadingSummary = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSummary();
      context.read<PetsProvider>().loadPets();
    });
  }

  Future<void> _loadSummary() async {
    try {
      final response = await _petApiService.getOwnerSummary(widget.ownerId);
      if (!mounted) return;
      setState(() {
        _ownerSummary = response;
        _isLoadingSummary = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoadingSummary = false;
      });
    }
  }

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('/')) {
      final baseUrl = dotenv.env['API_BASE_URL']?.trim() ?? 'http://localhost:5001';
      return '$baseUrl$imagePath';
    }
    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final petsProvider = context.watch<PetsProvider>();
    final ownerPets = petsProvider.allPets
        .where((pet) => pet.ownerId == widget.ownerId)
        .toList()
      ..sort((left, right) {
        if (left.isAvailable == right.isAvailable) return right.createdAt.compareTo(left.createdAt);
        return left.isAvailable ? -1 : 1;
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Listings'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<PetsProvider>().refreshPets(),
            _loadSummary(),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            if (_isLoadingSummary)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              )
            else
              _buildStats(context),
            const SizedBox(height: 16),
            _buildReviewsSection(context),
            const SizedBox(height: 16),
            Text(
              'All Pets',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (ownerPets.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.pets, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No pets listed by this owner',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...ownerPets.map((pet) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PetCard(pet: pet),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.18),
            child: const Icon(Icons.account_circle, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ownerName ?? _ownerSummary?['owner']?['ownerName']?.toString() ?? 'Owner',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.ownerContact ?? _ownerSummary?['owner']?['ownerContact']?.toString() ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final totalListed = _ownerSummary?['totalListed'] ?? 0;
    final soldCount = _ownerSummary?['soldCount'] ?? 0;
    final availableCount = _ownerSummary?['availableCount'] ?? 0;

    return Row(
      children: [
        Expanded(child: _StatCard(title: 'Listed', value: '$totalListed')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(title: 'Sold', value: '$soldCount')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(title: 'Available', value: '$availableCount')),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    final reviews = (_ownerSummary?['reviews'] as List?) ?? const [];
    final reviewCount = _ownerSummary?['reviewCount'] ?? 0;
    final averageRating = (_ownerSummary?['averageRating'] as num?)?.toDouble() ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Buyer Reviews',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (reviewCount > 0)
              Text(
                '${averageRating.toStringAsFixed(1)} / 5 • $reviewCount reviews',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No reviews yet.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else
          ...reviews.take(3).map((review) {
            final createdAt = review['createdAt'] != null
                ? DateTime.tryParse(review['createdAt'].toString())
                : null;
            final rating = (review['rating'] as num?)?.toDouble() ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, color: Colors.blue.shade700, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          review['buyerName']?.toString() ?? 'Buyer',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${rating.toStringAsFixed(0)} ★',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review['comment']?.toString() ?? '',
                    style: TextStyle(color: Colors.grey.shade800, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${review['petName']?.toString() ?? 'Pet'}${createdAt != null ? ' • ${DateFormat('MMM dd, yyyy').format(createdAt)}' : ''}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}