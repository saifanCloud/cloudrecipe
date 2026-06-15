import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_second_app/widgets/custom_loading.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'favorite_screen.dart';
import 'add_recipe_screen.dart';
import 'profile_screen.dart';
import 'recipe_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final RecipeService _recipeService = RecipeService();
  List<Recipe> historyRecipes = [];
  bool isLoading = true;

  static const primaryColor = Color(0xFF2C3E50);
  static const lightBg = Color(0xFFF8FAFC);
  static const textDark = Color(0xFF1E293B);
  static const textMedium = Color(0xFF64748B);
  static const cardWhite = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    final recipes = await _recipeService.fetchHistoryRecipes();
    if (mounted) {
      setState(() {
        historyRecipes = recipes;
        isLoading = false;
      });
    }
  }

  Future<void> _openRecipeDetail(Recipe recipe) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
    );
    if (mounted) _loadHistory();
  }

  Future<void> _handleLikeToggle(Recipe recipe) async {
    final oldStatus = recipe.isLiked;
    final oldLikes = recipe.likes;
    if (mounted) {
      setState(() {
        final idx = historyRecipes.indexWhere((r) => r.id == recipe.id);
        if (idx != -1) {
          historyRecipes[idx] = recipe.copyWith(
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
        final idx = historyRecipes.indexWhere((r) => r.id == recipe.id);
        if (idx != -1) {
          historyRecipes[idx] = recipe.copyWith(isSaved: !oldStatus);
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

  Widget _buildHistoryCard(Recipe recipe) {
    final description = _getDescription(recipe);
    return GestureDetector(
      onTap: () => _openRecipeDetail(recipe),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar di kiri
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                recipe.imageUrl ?? 'https://via.placeholder.com/300x200?text=No+Image',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: lightBg,
                  child: const Icon(Icons.broken_image, size: 30),
                ),
              ),
            ),
            // Konten di kanan
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor.withAlpha(51), width: 0.5),
                      ),
                      child: Text(
                        recipe.category,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: textMedium.withAlpha(204),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildActionChip(
                          icon: recipe.isLiked ? Icons.favorite : Icons.favorite_border,
                          label: '${recipe.likes}',
                          isActive: recipe.isLiked,
                          activeColor: Colors.red,
                          onTap: () => _handleLikeToggle(recipe),
                        ),
                        const SizedBox(width: 8),
                        _buildActionChip(
                          icon: recipe.isSaved ? Icons.bookmark : Icons.bookmark_border,
                          label: recipe.isSaved ? 'Saved' : 'Save',
                          isActive: recipe.isSaved,
                          activeColor: primaryColor,
                          onTap: () => _handleSaveToggle(recipe),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 3) return;
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
          "Explore (History)",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: isLoading
          ? const CustomLoadingIndicator()
          : historyRecipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 60, color: textMedium.withAlpha(128)),
                      const SizedBox(height: 16),
                      Text(
                        "No history yet",
                        style: GoogleFonts.poppins(fontSize: 16, color: textMedium),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Open a recipe from other screens\nto see it here",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 13, color: textMedium),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: historyRecipes.length,
                  itemBuilder: (context, index) => _buildHistoryCard(historyRecipes[index]),
                ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: 3,
        onTap: _onNavTap,
      ),
    );
  }
}