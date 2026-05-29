import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_second_app/widgets/custom_loading.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'favorite_screen.dart';
import 'add_recipe_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'recipe_detail_screen.dart';

// Widget tombol chip (like/save) – konsisten dengan halaman lain
class ActionChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const ActionChipButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? activeColor : const Color(0xFF64748B),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? activeColor : const Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  final RecipeService _recipeService = RecipeService();
  List<Recipe> savedRecipes = [];
  bool isLoading = true;

  static const primaryColor = Color(0xFF2C3E50);
  static const lightBg = Color(0xFFF8FAFC);
  static const textDark = Color(0xFF1E293B);
  static const textMedium = Color(0xFF64748B);
  static const cardWhite = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _loadSavedRecipes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSavedRecipes();
  }

  Future<void> _loadSavedRecipes() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    final recipes = await _recipeService.fetchSavedRecipes();
    if (mounted) {
      setState(() {
        savedRecipes = recipes;
        isLoading = false;
      });
    }
  }

  Future<void> _openRecipeDetail(Recipe recipe) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
    );
    if (mounted) _loadSavedRecipes();
  }

  Future<void> _handleLikeToggle(Recipe recipe) async {
    final oldStatus = recipe.isLiked;
    final oldLikes = recipe.likes;
    if (mounted) {
      setState(() {
        final idx = savedRecipes.indexWhere((r) => r.id == recipe.id);
        if (idx != -1) {
          savedRecipes[idx] = recipe.copyWith(
            isLiked: !oldStatus,
            likes: oldStatus ? oldLikes - 1 : oldLikes + 1,
          );
        }
      });
    }
    await _recipeService.toggleLike(recipe.id, oldStatus, oldLikes);
  }

  Future<void> _handleSaveToggle(Recipe recipe) async {
    final oldStatus = recipe.isSaved;
    if (mounted) {
      setState(() {
        final idx = savedRecipes.indexWhere((r) => r.id == recipe.id);
        if (idx != -1) {
          savedRecipes[idx] = recipe.copyWith(isSaved: !oldStatus);
        }
      });
    }
    await _recipeService.toggleSave(recipe.id, oldStatus);
    // Jika unsave, hapus dari daftar lokal
    if (oldStatus && mounted) {
      setState(() {
        savedRecipes.removeWhere((r) => r.id == recipe.id);
      });
    }
  }

  String _getRecipeSnippet(Recipe recipe) {
    if (recipe.ingredients.isNotEmpty && recipe.ingredients.first.isNotEmpty) {
      String snippet = recipe.ingredients.first;
      if (snippet.length > 35) snippet = snippet.substring(0, 35) + '...';
      return snippet;
    } else if (recipe.steps.isNotEmpty && recipe.steps.first.isNotEmpty) {
      String snippet = recipe.steps.first;
      if (snippet.length > 35) snippet = snippet.substring(0, 35) + '...';
      return snippet;
    }
    return 'No description';
  }

  Widget _buildSavedCard(Recipe recipe) {
    return GestureDetector(
      onTap: () => _openRecipeDetail(recipe),
      child: Container(
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: Image.network(
                recipe.imageUrl ?? 'https://via.placeholder.com/300x200?text=No+Image',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: lightBg,
                  child: const Icon(Icons.broken_image, size: 30),
                ),
              ),
            ),
            // Tombol like & save (chip di bawah gambar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionChipButton(
                    icon: recipe.isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '${recipe.likes}',
                    isActive: recipe.isLiked,
                    activeColor: Colors.red,
                    onTap: () => _handleLikeToggle(recipe),
                  ),
                  const SizedBox(width: 8),
                  ActionChipButton(
                    icon: recipe.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    label: recipe.isSaved ? 'Saved' : 'Save',
                    isActive: recipe.isSaved,
                    activeColor: primaryColor,
                    onTap: () => _handleSaveToggle(recipe),
                  ),
                ],
              ),
            ),
            // Teks (judul, kategori, cuplikan)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: textDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.category,
                    style: GoogleFonts.poppins(fontSize: 12, color: textMedium),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getRecipeSnippet(recipe),
                    style: GoogleFonts.poppins(fontSize: 11, color: textMedium.withValues(alpha: 0.8)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 4) return;
    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const FavoriteScreen();
        break;
      case 2:
        screen = const AddRecipeScreen();
        break;
      case 3:
        screen = const ExploreScreen();
        break;
      case 4:
        screen = const ProfileScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        title: Text(
          "Saved Recipes",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const CustomLoadingIndicator()
          : savedRecipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 60, color: textMedium.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        "No saved recipes",
                        style: GoogleFonts.poppins(fontSize: 16, color: textMedium),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap the bookmark icon on any recipe\nto save it here",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 13, color: textMedium),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: savedRecipes.length,
                  itemBuilder: (context, index) => _buildSavedCard(savedRecipes[index]),
                ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: 4,
        onTap: _onNavTap,
      ),
    );
  }
}