import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../providers/pets_provider.dart';
import '../models/pet_model.dart';
import '../models/category_model.dart';
import '../widgets/pet_card.dart';
import '../widgets/category_card.dart';
import '../services/pet_analysis_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final PetAnalysisService _analysisService = PetAnalysisService();
  String _searchQuery = '';
  Timer? _searchDebounce;
  bool _isAnalyzing = false;
  bool _showFilters = false;

  String? _selectedFilterCity;
  int? _minAge;
  int? _maxAge;
  double? _minPrice;
  double? _maxPrice;

  List<String> _availableFilterCities(List<PetModel> pets) {
    final cities = pets
        .map((pet) => (pet.city ?? '').trim())
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return cities;
  }

  bool get _hasActiveFilters =>
      _selectedFilterCity != null ||
      _minAge != null ||
      _maxAge != null ||
      _minPrice != null ||
      _maxPrice != null;

  String _emptyStateMessage() {
    if (_searchQuery.isNotEmpty) {
      return 'No pets found';
    }

    if (_selectedFilterCity != null && _selectedFilterCity!.isNotEmpty) {
      return 'No pets found in $_selectedFilterCity';
    }

    if (_hasActiveFilters) {
      return 'No pets match these filters';
    }

    return 'No pets available';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().authToken;
      if (token != null && token.isNotEmpty) {
        context.read<PetsProvider>().loadFavorites(token);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _captureAndSearchByCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        _showPetAnalysisDialog(image);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing camera: $e')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        _showPetAnalysisDialog(image);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing gallery: $e')),
      );
    }
  }

  void _showPetAnalysisDialog(XFile image) {
    showModalBottomSheet(
      context: context,
      isDismissible: !_isAnalyzing,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: _isAnalyzing
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                ),
                // Image Preview
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(image.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Analyze Button or Loading
                if (_isAnalyzing)
                  Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        const Text(
                          'Analyzing pet image...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('🔍 Analyze Pet with AI'),
                      onPressed: () => _analyzePetImage(File(image.path), context),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _analyzePetImage(File imageFile, BuildContext context) async {
    if (!mounted) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _analysisService.analyzePetImage(imageFile);

      if (!mounted) return;

      if (result['success'] == true) {
        // Close modal first, then show results
        if (mounted) Navigator.pop(context);
        if (mounted) _showAnalysisResults(result, context);
      } else {
        // Show error and close modal
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      // Close modal and show error
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showAnalysisResults(
      Map<String, dynamic> petDetails, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🐾 Pet Analysis Results'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Pet Type:',
                petDetails['petName'] ?? 'Unknown',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Breed:',
                petDetails['breed'] ?? 'Unknown',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Estimated Age:',
                petDetails['expectedAge'] ?? 'Unknown',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Origin:',
                petDetails['origin'] ?? 'Unknown',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              final breed = (petDetails['breed'] ?? '').toString().trim();
              final petType = (petDetails['petName'] ?? '').toString().trim();
              final searchTerm = breed.isNotEmpty &&
                      breed.toLowerCase() != 'unknown'
                  ? breed
                  : petType;

              // Search for breed first, then pet type if breed is unknown
              _searchController.text = searchTerm;
              setState(() {
                _searchQuery = searchTerm;
              });
              context.read<PetsProvider>().searchPets(searchTerm);
            },
            child: const Text('Search Similar Pets'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            width: 4,
            color: Colors.blue.shade700,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final petsProvider = context.watch<PetsProvider>();
    final categories = CategoryModel.getDummyCategories();
    final currentUserId = user?.id;

    final basePets = _searchQuery.isEmpty
      ? petsProvider.allPets
      : petsProvider.searchResults;

    final availableFilterCities = _availableFilterCities(petsProvider.allPets);

    final filteredPets = basePets.where((pet) {
      // Exclude current user's pets
      if (pet.ownerId == currentUserId) return false;
      
      // City filter
      if (_selectedFilterCity != null && _selectedFilterCity!.isNotEmpty) {
        final petCity = (pet.city ?? '').trim().toLowerCase();
        final filterCity = _selectedFilterCity!.trim().toLowerCase();
        if (petCity.isEmpty || petCity != filterCity) {
          return false;
        }
      }
      
      // Age filter
      if (_minAge != null && pet.age < _minAge!) return false;
      if (_maxAge != null && pet.age > _maxAge!) return false;
      
      // Price filter
      if (_minPrice != null && pet.price < _minPrice!) return false;
      if (_maxPrice != null && pet.price > _maxPrice!) return false;
      
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.pets, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFE3F2FD)],
              ).createShader(bounds),
              child: const Text(
                'PetiFy',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
              ),
              accountName: Text(
                user?.name ?? 'Guest User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'G',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('My Pets'),
              onTap: () {
                Navigator.pop(context);
                context.push('/my-pets');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
                context.push('/favorites');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('My Orders'),
              onTap: () {
                Navigator.pop(context);
                context.push('/my-orders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('My Sales'),
              onTap: () {
                Navigator.pop(context);
                context.push('/my-sales');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Chats'),
              onTap: () {
                Navigator.pop(context);
                context.push('/chats');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                context.read<AuthProvider>().logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await petsProvider.refreshPets();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with gradient and search bar
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade700,
                      Colors.blue.shade400,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Your Perfect Pet',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse through our collection of pets',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                    const SizedBox(height: 20),
                    // Search Bar with Camera Button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                              _searchDebounce?.cancel();
                              if (value.trim().isEmpty) {
                                context.read<PetsProvider>().clearSearch();
                                setState(() {
                                  _searchQuery = '';
                                });
                                return;
                              }
                              _searchDebounce = Timer(const Duration(milliseconds: 350), () {
                                context.read<PetsProvider>().searchPets(value);
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search pets by name or category...',
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Camera & Gallery Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: PopupMenuButton<String>(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            tooltip: 'Search by image',
                            onSelected: (String value) {
                              if (value == 'camera') {
                                _captureAndSearchByCamera();
                              } else if (value == 'gallery') {
                                _pickFromGallery();
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'camera',
                                child: Row(
                                  children: [
                                    const Icon(Icons.camera_alt, size: 20),
                                    const SizedBox(width: 12),
                                    const Text('Take Photo'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'gallery',
                                child: Row(
                                  children: [
                                    const Icon(Icons.image, size: 20),
                                    const SizedBox(width: 12),
                                    const Text('Upload from Gallery'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Categories section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/categories');
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return CategoryCard(category: categories[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Filters',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            Icon(
                              _showFilters ? Icons.expand_less : Icons.expand_more,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Filter Panel (Expandable)
              if (_showFilters)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // City Filter
                          Text(
                            'Location',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (availableFilterCities.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Text(
                                'No pet locations available yet',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            )
                          else
                          DropdownButtonFormField<String>(
                            value: availableFilterCities.contains(_selectedFilterCity)
                                ? _selectedFilterCity
                                : null,
                            items: [
                              ...availableFilterCities.map(
                                (city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ),
                              )
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedFilterCity = (value == null || value.isEmpty) ? null : value;
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.location_on, color: Colors.blue.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                            ),
                            hint: const Text('All cities'),
                          ),
                          const SizedBox(height: 20),

                          // Age Range Filter
                          Text(
                            'Age (months)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _minAge = int.tryParse(value);
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Min',
                                    prefixIcon: Icon(Icons.arrow_downward, color: Colors.blue.shade700, size: 18),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.blue.shade200),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.blue.shade200),
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue.shade50,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _maxAge = int.tryParse(value);
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Max',
                                    prefixIcon: Icon(Icons.arrow_upward, color: Colors.blue.shade700, size: 18),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.blue.shade200),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.blue.shade200),
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue.shade50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Price Range Filter
                          Text(
                            'Price (\$)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _minPrice = double.tryParse(value);
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Min',
                                    prefixIcon: Icon(Icons.attach_money, color: Colors.blue.shade700, size: 18),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.blue.shade200),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.blue.shade200),
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue.shade50,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _maxPrice = double.tryParse(value);
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Max',
                                    prefixIcon: Icon(Icons.payments, color: Colors.blue.shade700, size: 18),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.blue.shade200),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.blue.shade200),
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue.shade50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Clear Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedFilterCity = null;
                                  _minAge = null;
                                  _maxAge = null;
                                  _minPrice = null;
                                  _maxPrice = null;
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset Filters'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue.shade700,
                                side: BorderSide(color: Colors.blue.shade700),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Top Selling Pets section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _searchQuery.isEmpty ? 'Featured Pets' : 'Search Results',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),
                        (_searchQuery.isEmpty
                          ? petsProvider.isLoading
                          : petsProvider.isSearching)
                        ? const Center(child: CircularProgressIndicator())
                        : filteredPets.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _emptyStateMessage(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredPets.length,
                                itemBuilder: (context, index) {
                                  return PetCard(
                                    pet: filteredPets[index],
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-pet');
        },
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Sell Your Pet', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
