import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pets_provider.dart';
import '../input_formatters/pakistan_mobile_suffix_formatter.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _ownerContactController = TextEditingController();

  String? _selectedCategory;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  final categories = CategoryModel.getDummyCategories();
  static const Map<String, List<String>> _breedSuggestions = {
    'Dogs': [
      'German Shepherd',
      'Labrador Retriever',
      'Golden Retriever',
      'Poodle',
      'Beagle',
      'Bulldog',
      'Rottweiler',
      'Shih Tzu',
    ],
    'Cats': [
      'Persian Cat',
      'Siamese',
      'Maine Coon',
      'British Shorthair',
      'Ragdoll',
      'Bengal',
      'Sphynx',
      'Scottish Fold',
    ],
    'Birds': [
      'Parakeet',
      'Cockatiel',
      'African Grey',
      'Macaw',
      'Canary',
      'Lovebird',
      'Cockatoo',
    ],
    'Fish': [
      'Goldfish',
      'Betta Fish',
      'Guppy',
      'Angelfish',
      'Molly',
      'Tetra',
    ],
    'Rabbits': [
      'Holland Lop',
      'Netherland Dwarf',
      'Lionhead',
      'Flemish Giant',
      'Mini Rex',
      'English Angora',
    ],
    'Hamsters': [
      'Syrian Hamster',
      'Dwarf Hamster',
      'Roborovski Hamster',
      'Campbells Dwarf Hamster',
      'Winter White Hamster',
    ],
  };

  List<String> get _currentBreedSuggestions {
    if (_selectedCategory == null) return const [];
    return _breedSuggestions[_selectedCategory!] ?? const [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ownerContactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final petsProvider = context.read<PetsProvider>();
    final token = authProvider.authToken;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated. Please login again.')),
      );
      return;
    }

    final success = await petsProvider.addPet(
      token: token,
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      breed: _breedController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      ownerContact: PakistanMobileSuffixFormatter.toFullPakNumber(
        _ownerContactController.text,
      ),
      imagePath: _imagePath,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(petsProvider.errorMessage ?? 'Failed to add pet'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Your Pet'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Pet Photo',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Pet Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Pet Name',
                  hintText: 'Enter pet name',
                  prefixIcon: const Icon(Icons.pets),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pet name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Text('${category.icon} ${category.name}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    if (_breedController.text.isNotEmpty &&
                        !_currentBreedSuggestions
                            .map((breed) => breed.toLowerCase())
                            .contains(_breedController.text.trim().toLowerCase())) {
                      _breedController.clear();
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Breed
              TextFormField(
                controller: _breedController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Breed',
                  hintText: _selectedCategory == null
                      ? 'Select a category first'
                      : 'Type breed or choose a suggestion',
                  prefixIcon: const Icon(Icons.fingerprint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter breed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              if (_currentBreedSuggestions.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Suggested breeds for $_selectedCategory',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _currentBreedSuggestions.map((breed) {
                    final isSelected =
                        _breedController.text.trim().toLowerCase() == breed.toLowerCase();
                    return ChoiceChip(
                      label: Text(breed),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _breedController.text = breed;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 16),

              // Age
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age (months)',
                  hintText: 'Enter age in months',
                  prefixIcon: const Icon(Icons.cake),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price (\$)',
                  hintText: 'Enter price',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Tell us about your pet',
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Owner Contact (Pakistan mobile: fixed 03 + XX-XXXXXXX)
              TextFormField(
                controller: _ownerContactController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  PakistanMobileSuffixFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  hintText: '40-8432739',
                  helperText: 'Pakistan mobile — 03 is fixed, enter 9 more digits',
                  prefixIcon: const Icon(Icons.phone),
                  prefixText: '03 ',
                  prefixStyle:
                      Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  final digits =
                      PakistanMobileSuffixFormatter.normalizeSuffixDigits(
                    value,
                  );
                  if (digits.length !=
                      PakistanMobileSuffixFormatter.maxDigitsAfterPrefix) {
                    return 'Enter a complete number (9 digits after 03)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _savePet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Pet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
