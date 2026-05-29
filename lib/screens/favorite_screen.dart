import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_second_app/widgets/custom_loading.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'add_recipe_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'recipe_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final RecipeService _recipeService = RecipeService();
  List<Recipe> favoriteRecipes = [];
  bool isLoading = true;

  static const primaryColor = Color(0xFF2C3E50);
  static const lightBg = Color(0xFFF8FAFC);
  static const textDark = Color(0xFF1E293B);
  static const textMedium = Color(0xFF64748B);
  static const cardWhite = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    final recipes = await _recipeService.fetchFavoriteRecipes();
    if (mounted) {
      setState(() {
        favoriteRecipes = recipes;
        isLoading = false;
      });
    }
  }

  Future<void> _openRecipeDetail(Recipe recipe) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
    );
    if (mounted) _loadFavorites();
  }

  Future<void> _handleLikeToggle(Recipe recipe) async {
    final oldStatus = recipe.isLiked;
    final oldLikes = recipe.likes;
    if (mounted) {
      setState(() {
        final idx = favoriteRecipes.indexWhere((r) => r.id == recipe.id);
        if (idx != -1) {
          favoriteRecipes[idx] = recipe.copyWith(
            isLiked: !oldStatus,
            likes: oldStatus ? oldLikes - 1 : oldLikes + 1,
          );
        }
      });
    }
    await _recipeService.toggleLike(recipe.id, oldStatus, oldLikes);
    if (mounted) _loadFavorites();
  }

  Future<void> _handleSaveToggle(Recipe recipe) async {
    final oldStatus = recipe.isSaved;
    if (mounted) {
      setState(() {
        final idx = favoriteRecipes.indexWhere((r) => r.id == recipe.id);
        if (idx != -1) {
          favoriteRecipes[idx] = recipe.copyWith(isSaved: !oldStatus);
        }
      });
    }
    await _recipeService.toggleSave(recipe.id, oldStatus);
  }

  String _getDescription(Recipe recipe) {
    if (recipe.description != null && recipe.description!.isNotEmpty) {
      return recipe.description!;
    }
    return '';
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? activeColor : textMedium,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? activeColor : textMedium),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    final description = _getDescription(recipe);
    return GestureDetector(
      onTap: () => _openRecipeDetail(recipe),
      child: Container(
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            // Jarak gambar -> tombol (sama dengan Explore: 8)
            const SizedBox(height: 8),
            // Baris tombol like & save
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionChip(
                    icon: recipe.isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '${recipe.likes}',
                    isActive: recipe.isLiked,
                    activeColor: Colors.red,
                    onTap: () => _handleLikeToggle(recipe),
                  ),
                  const SizedBox(width: 12),
                  _buildActionChip(
                    icon: recipe.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    label: recipe.isSaved ? 'Saved' : 'Save',
                    isActive: recipe.isSaved,
                    activeColor: primaryColor,
                    onTap: () => _handleSaveToggle(recipe),
                  ),
                ],
              ),
            ),
            // Jarak tombol -> nama (sama dengan Explore: 8)
            const SizedBox(height: 8),
            // Nama resep (font 14)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                recipe.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textDark,
                ),
              ),
            ),
            // Jarak nama -> tag (sama dengan Explore: 6)
            const SizedBox(height: 6),
            // Tag (kategori) dengan gaya pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withAlpha(51), width: 0.5),
                ),
                child: Text(
                  recipe.category,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
            // Jarak tag -> deskripsi (sama dengan Explore: 8)
            const SizedBox(height: 8),
            // Deskripsi (tinggi tetap 36, font 12)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 36,
                child: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textMedium.withAlpha(204),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 1) return;
    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
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
          "My Favorites",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const CustomLoadingIndicator()
          : favoriteRecipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 60, color: textMedium.withAlpha(128)),
                      const SizedBox(height: 16),
                      Text(
                        "No favorites yet",
                        style: GoogleFonts.poppins(fontSize: 16, color: textMedium),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap the heart icon on any recipe",
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
                  itemCount: favoriteRecipes.length,
                  itemBuilder: (context, index) => _buildRecipeCard(favoriteRecipes[index]),
                ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: 1,
        onTap: _onNavTap,
      ),
    );
  }
}