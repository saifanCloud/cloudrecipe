import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final RecipeService _recipeService = RecipeService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Breakfast';
  final List<TextEditingController> _ingredientControllers = [TextEditingController()];
  final List<TextEditingController> _stepControllers = [TextEditingController()];

  Uint8List? _selectedImageBytes;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> _categories = const [
    {'name': 'Breakfast', 'icon': '🍳'},
    {'name': 'Lunch', 'icon': '🥗'},
    {'name': 'Dinner', 'icon': '🍝'},
    {'name': 'Snack', 'icon': '🍿'},
    {'name': 'Cuisine', 'icon': '🍜'},
    {'name': 'Smoothies', 'icon': '🥤'},
    {'name': 'Dessert', 'icon': '🍰'},
    {'name': 'Pudding', 'icon': '🍮'},
    {'name': 'Bread', 'icon': '🥖'},
  ];

  static const primaryColor = Color(0xFF2C3E50);
  static const lightBg = Color(0xFFF8FAFC);
  static const textDark = Color(0xFF1E293B);
  static const textMedium = Color(0xFF64748B);
  static const cardWhite = Color(0xFFFFFFFF);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _ingredientControllers) controller.dispose();
    for (final controller in _stepControllers) controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      final bytes = await picked.readAsBytes();
      if (mounted) setState(() => _selectedImageBytes = bytes);
    }
  }

  Future<void> _showCategoryPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: cardWhite,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: textMedium.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Select Category',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textDark)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat['name'] == _selectedCategory;
                        return GestureDetector(
                          onTap: () => Navigator.pop(context, cat['name']),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : lightBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSelected ? primaryColor : Colors.transparent, width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(cat['icon']!, style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(
                                  cat['name']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? Colors.white : textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (selected != null && mounted) setState(() => _selectedCategory = selected);
  }

  Future<void> _submitRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar terlebih dahulu')),
      );
      return;
    }

    setState(() => _isUploading = true);

    String? imageUrl;
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      imageUrl = await _recipeService.uploadImageBytes(_selectedImageBytes!, fileName);
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload gambar: $e')));
      }
      return;
    }

    if (imageUrl == null) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal upload gambar (null)')),
        );
      }
      return;
    }

    final ingredients = _ingredientControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    final steps = _stepControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    final description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login terlebih dahulu')),
        );
      }
      return;
    }

    final newRecipe = Recipe(
      id: '',
      title: _titleController.text.trim(),
      imageUrl: imageUrl,
      category: _selectedCategory,
      description: description,
      ingredients: ingredients,
      steps: steps,
      authorName: currentUser.email?.split('@').first ?? 'User',
      authorAvatar: currentUser.userMetadata?['avatar_url'],
      userId: currentUser.id,
    );

    final addedRecipe = await _recipeService.addRecipe(newRecipe);
    if (mounted) {
      setState(() => _isUploading = false);
      if (addedRecipe != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil ditambahkan!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan resep')),
        );
      }
    }
  }

  void _addIngredient() => setState(() => _ingredientControllers.add(TextEditingController()));
  void _removeIngredient(int index) => setState(() => _ingredientControllers.removeAt(index));
  void _addStep() => setState(() => _stepControllers.add(TextEditingController()));
  void _removeStep(int index) => setState(() => _stepControllers.removeAt(index));

  @override
  Widget build(BuildContext context) {
    final selectedCatIcon = _categories.firstWhere((cat) => cat['name'] == _selectedCategory)['icon'];

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        title: Text('Add New Recipe', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                      image: _selectedImageBytes != null
                          ? DecorationImage(image: MemoryImage(_selectedImageBytes!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _selectedImageBytes == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 50, color: textMedium),
                              const SizedBox(height: 8),
                              Text('Tap to select image', style: GoogleFonts.poppins(fontSize: 14, color: textMedium)),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          style: GoogleFonts.poppins(),
                          decoration: InputDecoration(
                            labelText: 'Recipe Title',
                            labelStyle: GoogleFonts.poppins(color: textMedium),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: primaryColor),
                            ),
                            filled: true,
                            fillColor: lightBg,
                          ),
                          validator: (v) => v!.isEmpty ? 'Enter title' : null,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _showCategoryPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: lightBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.transparent),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(selectedCatIcon!, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Category', style: GoogleFonts.poppins(fontSize: 12, color: textMedium)),
                                        Text(_selectedCategory,
                                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: textDark)),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_drop_down, color: primaryColor, size: 28),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          style: GoogleFonts.poppins(),
                          maxLength: 200,  // batas 200 karakter
                          decoration: InputDecoration(
                            labelText: 'Description (optional)',
                            labelStyle: GoogleFonts.poppins(color: textMedium),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: primaryColor),
                            ),
                            filled: true,
                            fillColor: lightBg,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ingredients', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textDark)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 24),
                              onPressed: _addIngredient,
                              color: primaryColor,
                            ),
                          ],
                        ),
                        ..._buildDynamicFields(_ingredientControllers, 'Ingredient', _removeIngredient),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Steps', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textDark)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 24),
                              onPressed: _addStep,
                              color: primaryColor,
                            ),
                          ],
                        ),
                        ..._buildDynamicFields(_stepControllers, 'Step', _removeStep, maxLines: 3),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUploading ? null : _submitRecipe,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isUploading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(primaryColor)),
                                  )
                                : Text('Publish Recipe', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          if (_isUploading) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicFields(
    List<TextEditingController> controllers,
    String label,
    Function(int) onRemove, {
    int maxLines = 1,
  }) {
    return List.generate(controllers.length, (idx) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers[idx],
                decoration: InputDecoration(
                  hintText: '$label ${idx + 1}',
                  hintStyle: GoogleFonts.poppins(color: textMedium),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: lightBg,
                ),
                maxLines: maxLines,
                validator: (v) => v!.isEmpty ? 'Required' : null,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              onPressed: controllers.length > 1 ? () => onRemove(idx) : null,
            ),
          ],
        ),
      );
    });
  }
}