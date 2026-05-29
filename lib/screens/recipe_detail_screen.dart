import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../utils/app_colors.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe _recipe;
  final RecipeService _recipeService = RecipeService();
  bool _isProcessing = false;

  static const primaryColor = Color(0xFF2C3E50);
  static const lightBg = Color(0xFFF8FAFC);
  static const textDark = Color(0xFF1E293B);
  static const textMedium = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    _recipeService.addToHistory(_recipe.id);
  }

  Future<void> _toggleLike() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final oldStatus = _recipe.isLiked;
    final oldLikes = _recipe.likes;
    setState(() {
      _recipe = _recipe.copyWith(
        isLiked: !oldStatus,
        likes: oldStatus ? oldLikes - 1 : oldLikes + 1,
      );
    });
    await _recipeService.toggleLike(_recipe.id, oldStatus, oldLikes);
    setState(() => _isProcessing = false);
  }

  Future<void> _toggleSave() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final oldStatus = _recipe.isSaved;
    setState(() {
      _recipe = _recipe.copyWith(isSaved: !oldStatus);
    });
    await _recipeService.toggleSave(_recipe.id, oldStatus);
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final authorName = _recipe.authorName ?? 'Anonymous';
    final authorInitial = authorName.isNotEmpty ? authorName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        title: Text(
          _recipe.title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                _recipe.imageUrl ?? 'https://via.placeholder.com/400x250?text=No+Image',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: AppColors.lightGrey,
                  child: const Icon(Icons.broken_image, size: 60),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Author info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryColor,
                      child: Text(
                        authorInitial,
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Posted by',
                          style: GoogleFonts.poppins(fontSize: 10, color: textMedium),
                        ),
                        Text(
                          authorName,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: textDark),
                        ),
                      ],
                    ),
                  ],
                ),
                // Action buttons
                Wrap(
                  spacing: 8,
                  children: [
                    _buildActionButton(
                      icon: _recipe.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _recipe.isLiked ? Colors.red : textMedium,
                      label: '${_recipe.likes}',
                      onTap: _toggleLike,
                    ),
                    _buildActionButton(
                      icon: _recipe.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: _recipe.isSaved ? primaryColor : textMedium,
                      label: _recipe.isSaved ? 'Saved' : 'Save',
                      onTap: _toggleSave,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _recipe.category,
                style: GoogleFonts.poppins(fontSize: 12, color: primaryColor),
              ),
            ),
            // 🆕 Deskripsi (jika ada)
            if (_recipe.description != null && _recipe.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _recipe.description!,
                style: GoogleFonts.poppins(fontSize: 14, height: 1.4, color: textDark),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              "Ingredients",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
            ),
            const SizedBox(height: 8),
            ..._recipe.ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ing,
                          style: GoogleFonts.poppins(fontSize: 15, color: textDark),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            Text(
              "Steps",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
            ),
            const SizedBox(height: 8),
            ..._recipe.steps.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: GoogleFonts.poppins(fontSize: 15, color: textDark),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}