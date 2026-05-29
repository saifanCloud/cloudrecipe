// lib/screens/home_screen.dart (full code)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_second_app/widgets/custom_loading.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';
import '../models/category_model.dart';
import '../utils/dummy_data.dart';
import '../services/recipe_service.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/category_grid.dart';
import 'favorite_screen.dart';
import 'add_recipe_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'recipe_detail_screen.dart';

// Widget untuk tombol aksi (like/save) gaya chip
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

// Kartu trending dengan deskripsi, jarak rapi, shadow konsisten dengan favorite screen
class TrendingRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback? onTap;

  const TrendingRecipeCard({
    super.key,
    required this.recipe,
    required this.onLike,
    required this.onSave,
    this.onTap,
  });

  String _getDescription(Recipe recipe) {
    if (recipe.description != null && recipe.description!.isNotEmpty) {
      return recipe.description!;
    } else if (recipe.ingredients.isNotEmpty) {
      String full = recipe.ingredients.join(', ');
      if (full.length > 80) full = full.substring(0, 77) + '...';
      return '🧑‍🍳 ' + full;
    } else if (recipe.steps.isNotEmpty && recipe.steps.first.isNotEmpty) {
      String snippet = recipe.steps.first;
      if (snippet.length > 80) snippet = snippet.substring(0, 77) + '...';
      return '📝 ' + snippet;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final description = _getDescription(recipe);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Image.network(
                recipe.imageUrl ?? 'https://via.placeholder.com/200x140?text=No+Image',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: const Color(0xFFF8FAFC),
                  child: const Icon(Icons.broken_image, size: 40, color: Color(0xFF64748B)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Tombol like & save
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionChipButton(
                    icon: recipe.isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '${recipe.likes}',
                    isActive: recipe.isLiked,
                    activeColor: Colors.red,
                    onTap: onLike,
                  ),
                  const SizedBox(width: 8),
                  ActionChipButton(
                    icon: recipe.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    label: recipe.isSaved ? 'Saved' : 'Save',
                    isActive: recipe.isSaved,
                    activeColor: const Color(0xFF2C3E50),
                    onTap: onSave,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Nama resep
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                recipe.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Kategori (tag pill)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50).withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2C3E50).withAlpha(51), width: 0.5),
                ),
                child: Text(
                  recipe.category,
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF2C3E50)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Deskripsi (jika ada, jika tidak tetap beri ruang kosong agar tinggi konsisten)
            description.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B).withAlpha(204)),
                    ),
                  )
                : const SizedBox(height: 36),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Category> categories = [];
  List<Recipe> allTrendingRecipes = [];
  List<Recipe> displayedRecipes = [];
  final RecipeService _recipeService = RecipeService();
  bool _isLoading = true;
  String _searchQuery = '';

  String? userName;
  String? userAvatar;

  static const primaryColor = Color(0xFF2C3E50);
  static const lightBg = Color(0xFFF8FAFC);
  static const textDark = Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    categories = List.from(dummyCategories);
    _resetToMoreCategory();
    _loadUserProfile();
    _loadRecipes(null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final metadata = user.userMetadata;
      setState(() {
        userName = metadata?['name'] ?? user.email?.split('@').first;
        userAvatar = metadata?['avatar_url'];
      });
    }
  }

  void _resetToMoreCategory() {
    final moreIndex = categories.indexWhere((cat) => cat.name == 'More');
    if (moreIndex != -1) {
      for (int i = 0; i < categories.length; i++) {
        categories[i].isActive = (i == moreIndex);
      }
    }
  }

  Future<void> _loadRecipes(String? category) async {
    setState(() => _isLoading = true);
    final allRecipes = await _recipeService.fetchAllRecipes();
    List<Recipe> filtered = List.from(allRecipes);
    if (category != null && category != 'More') {
      filtered = filtered.where((recipe) => recipe.category == category).toList();
    }
    if (filtered.length > 10) {
      filtered = filtered.sublist(0, 10);
    }
    setState(() {
      allTrendingRecipes = filtered;
      _searchQuery = '';
      _searchController.clear();
      _applySearchFilter();
      _isLoading = false;
    });
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      displayedRecipes = List.from(allTrendingRecipes);
    } else {
      displayedRecipes = allTrendingRecipes.where((recipe) {
        return recipe.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applySearchFilter();
    });
  }

  void _onCategoryTap(int index) {
    final selectedCategory = categories[index];
    setState(() {
      for (int i = 0; i < categories.length; i++) {
        categories[i].isActive = (i == index);
      }
    });
    _loadRecipes(selectedCategory.name == 'More' ? null : selectedCategory.name);
  }

  Future<void> _toggleLike(Recipe recipe) async {
    final oldLikes = recipe.likes;
    final oldStatus = recipe.isLiked;
    setState(() {
      final idxAll = allTrendingRecipes.indexWhere((r) => r.id == recipe.id);
      if (idxAll != -1) {
        allTrendingRecipes[idxAll] = recipe.copyWith(
          isLiked: !oldStatus,
          likes: oldStatus ? oldLikes - 1 : oldLikes + 1,
        );
      }
      final idxDisplay = displayedRecipes.indexWhere((r) => r.id == recipe.id);
      if (idxDisplay != -1) {
        displayedRecipes[idxDisplay] = allTrendingRecipes[idxAll];
      }
    });
    await _recipeService.toggleLike(recipe.id, oldStatus, oldLikes);
  }

  Future<void> _toggleSave(Recipe recipe) async {
    final oldStatus = recipe.isSaved;
    setState(() {
      final idxAll = allTrendingRecipes.indexWhere((r) => r.id == recipe.id);
      if (idxAll != -1) {
        allTrendingRecipes[idxAll] = recipe.copyWith(isSaved: !oldStatus);
      }
      final idxDisplay = displayedRecipes.indexWhere((r) => r.id == recipe.id);
      if (idxDisplay != -1) {
        displayedRecipes[idxDisplay] = allTrendingRecipes[idxAll];
      }
    });
    await _recipeService.toggleSave(recipe.id, oldStatus);
  }

  Future<void> _openRecipeDetail(Recipe recipe) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
    );
    final activeCategory = categories.firstWhere((cat) => cat.isActive, orElse: () => categories.last);
    _loadRecipes(activeCategory.name == 'More' ? null : activeCategory.name);
  }

  void _onNavTap(int index) async {
    if (index == 0) return;
    if (index == 2) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
      );
      if (result == true) {
        final activeCategory = categories.firstWhere((cat) => cat.isActive, orElse: () => categories.last);
        _loadRecipes(activeCategory.name == 'More' ? null : activeCategory.name);
      }
    } else {
      Widget screen;
      switch (index) {
        case 1:
          screen = const FavoriteScreen();
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
      await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      if (index == 4) _loadUserProfile();
      final activeCategory = categories.firstWhere((cat) => cat.isActive, orElse: () => categories.last);
      _loadRecipes(activeCategory.name == 'More' ? null : activeCategory.name);
    }
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final safeDisplayedRecipes = displayedRecipes;
    final List<Recipe> topRowRecipes = safeDisplayedRecipes.length > 5
        ? safeDisplayedRecipes.sublist(0, 5)
        : List.from(safeDisplayedRecipes);
    final List<Recipe> bottomRowRecipes = safeDisplayedRecipes.length > 5
        ? safeDisplayedRecipes.sublist(5)
        : <Recipe>[];

    final Widget avatarWidget = userAvatar == null
        ? CircleAvatar(
            radius: 20,
            backgroundColor: primaryColor,
            child: Text(
              userName?.substring(0, 1).toUpperCase() ?? '?',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
            ),
          )
        : CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(userAvatar!),
            onBackgroundImageError: (_, __) {},
          );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: avatarWidget,
        ),
        title: Text(
          "What's cooking today${userName != null ? ', $userName' : ''}?",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: textDark, size: 24),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const CustomLoadingIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    CustomSearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Categories",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
                    ),
                    const SizedBox(height: 12),
                    CategoryGrid(
                      categories: categories,
                      onCategoryTap: _onCategoryTap,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Trending Recipe",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
                    ),
                    const SizedBox(height: 12),
                    safeDisplayedRecipes.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text("Tidak ada resep yang cocok"),
                            ),
                          )
                        : Column(
                            children: [
                              SizedBox(
                                height: 310,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: topRowRecipes.length,
                                  itemBuilder: (context, index) {
                                    final recipe = topRowRecipes[index];
                                    return TrendingRecipeCard(
                                      recipe: recipe,
                                      onLike: () => _toggleLike(recipe),
                                      onSave: () => _toggleSave(recipe),
                                      onTap: () => _openRecipeDetail(recipe),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (bottomRowRecipes.isNotEmpty)
                                SizedBox(
                                  height: 310,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: bottomRowRecipes.length,
                                    itemBuilder: (context, index) {
                                      final recipe = bottomRowRecipes[index];
                                      return TrendingRecipeCard(
                                        recipe: recipe,
                                        onLike: () => _toggleLike(recipe),
                                        onSave: () => _toggleSave(recipe),
                                        onTap: () => _openRecipeDetail(recipe),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}