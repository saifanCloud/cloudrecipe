import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_second_app/widgets/custom_loading.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/recipe_service.dart';
import '../models/recipe_model.dart';
import '../utils/app_colors.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import 'login_screen.dart';
import 'saved_recipes_screen.dart';
import 'edit_recipe_screen.dart';
import 'home_screen.dart';
import 'favorite_screen.dart';
import 'add_recipe_screen.dart';
import 'explore_screen.dart';
import 'recipe_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final RecipeService _recipeService = RecipeService();
  List<Recipe> userRecipes = [];
  bool isLoading = true;

  String? displayName;
  String? avatarUrl;
  bool isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;
  bool _isUploading = false;

  static const primaryColor = Color(0xFF2C3E50);
  static const accentColor = Color(0xFF3498DB);
  static const lightBg = Color(0xFFF8FAFC);
  static const textDark = Color(0xFF1E293B);
  static const textMedium = Color(0xFF64748B);
  static const cardWhite = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserRecipes();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final metadata = user.userMetadata;
      if (mounted) {
        setState(() {
          displayName = metadata?['name'] ?? user.email?.split('@').first;
          avatarUrl = metadata?['avatar_url'];
        });
        _nameController.text = displayName ?? '';
      }
    }
  }

  Future<void> _loadUserRecipes() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      if (mounted) setState(() => isLoading = true);
      final recipes = await _recipeService.fetchUserRecipes(user.id);
      if (mounted) {
        setState(() {
          userRecipes = recipes;
          isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama tidak boleh kosong')),
        );
      }
      return;
    }

    setState(() => _isUploading = true);

    String? newAvatarUrl = avatarUrl;
    if (_selectedImageBytes != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      try {
        await Supabase.instance.client.storage.from('avatars').uploadBinary(
              fileName,
              _selectedImageBytes!,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
        newAvatarUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal upload foto: $e')),
          );
          setState(() => _isUploading = false);
        }
        return;
      }
    }

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'name': newName,
            'avatar_url': newAvatarUrl,
          },
        ),
      );
      if (mounted) {
        setState(() {
          displayName = newName;
          avatarUrl = newAvatarUrl;
          isEditing = false;
          _selectedImageBytes = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      final bytes = await picked.readAsBytes();
      if (mounted) {
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  Future<void> _confirmDelete(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Resep'),
        content: Text('Apakah Anda yakin ingin menghapus "${recipe.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menghapus resep...'), duration: Duration(seconds: 1)),
      );
      final success = await _recipeService.deleteRecipe(recipe.id);
      if (mounted) {
        if (success) {
          setState(() {
            userRecipes.removeWhere((r) => r.id == recipe.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resep berhasil dihapus'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus resep, coba lagi nanti'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  String _getDescription(Recipe recipe) {
    if (recipe.description != null && recipe.description!.isNotEmpty) {
      return recipe.description!;
    } else if (recipe.ingredients.isNotEmpty && recipe.ingredients.first.isNotEmpty) {
      String snippet = recipe.ingredients.first;
      if (snippet.length > 80) snippet = snippet.substring(0, 77) + '...';
      return '🧑‍🍳 ' + snippet;
    } else if (recipe.steps.isNotEmpty && recipe.steps.first.isNotEmpty) {
      String snippet = recipe.steps.first;
      if (snippet.length > 80) snippet = snippet.substring(0, 77) + '...';
      return '📝 ' + snippet;
    }
    return '';
  }

  Widget _buildRecipeCard(Recipe recipe) {
    final description = _getDescription(recipe);
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
        );
        if (mounted) _loadUserRecipes();
      },
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
      default:
        return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';

    ImageProvider? imageProvider;
    if (_selectedImageBytes != null) {
      imageProvider = MemoryImage(_selectedImageBytes!);
    } else if (avatarUrl != null) {
      imageProvider = NetworkImage(avatarUrl!);
    } else {
      imageProvider = null;
    }

    final bool hasImage = imageProvider != null;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red, size: 24),
            onPressed: _signOut,
          ),
        ],
      ),
      body: isLoading
          ? const CustomLoadingIndicator()
          : Column(
              children: [
                // Profile Header Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withAlpha(51),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: primaryColor,
                              backgroundImage: imageProvider,
                              child: !hasImage
                                  ? Text(
                                      displayName?.substring(0, 1).toUpperCase() ?? '?',
                                      style: GoogleFonts.poppins(fontSize: 45, color: Colors.white),
                                    )
                                  : null,
                            ),
                          ),
                          if (isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: accentColor,
                                radius: 18,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                  onPressed: _pickImage,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isEditing)
                            Text(
                              displayName ?? email.split('@').first,
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: textDark),
                            )
                          else
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: 'Nama',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                          if (!isEditing)
                            IconButton(
                              icon: Icon(Icons.edit, color: textDark, size: 20),
                              onPressed: () {
                                setState(() {
                                  isEditing = true;
                                  _nameController.text = displayName ?? '';
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: GoogleFonts.poppins(fontSize: 13, color: textMedium),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statItem("${userRecipes.length}", "Recipes"),
                          _statItem("1.2k", "Followers"),
                          _statItem("234", "Following"),
                        ],
                      ),
                    ],
                  ),
                ),
                // My Recipes Section dengan tombol Saved
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Recipes",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedRecipesScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor.withAlpha(26),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: primaryColor, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.bookmark, size: 14, color: primaryColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Saved",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isEditing) ...[
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _isUploading ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                minimumSize: const Size(60, 32),
                              ),
                              child: _isUploading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text("Save", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Recipe List dengan tombol edit dan hapus di pojok kanan atas
                Expanded(
                  child: userRecipes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_menu, size: 60, color: textMedium.withAlpha(128)),
                              const SizedBox(height: 12),
                              Text(
                                "No recipes yet",
                                style: GoogleFonts.poppins(fontSize: 16, color: textMedium),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap + button to add your first recipe",
                                style: GoogleFonts.poppins(fontSize: 13, color: textMedium),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: userRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = userRecipes[index];
                            final description = _getDescription(recipe);
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                                );
                                if (mounted) _loadUserRecipes();
                              },
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
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
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
                                                // Tombol edit dan hapus di pojok kanan atas
                                                Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.withAlpha(26),
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: IconButton(
                                                        icon: const Icon(Icons.edit, size: 16, color: primaryColor),
                                                        padding: const EdgeInsets.all(4),
                                                        constraints: const BoxConstraints(),
                                                        onPressed: () async {
                                                          final result = await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (_) => EditRecipeScreen(recipe: recipe)),
                                                          );
                                                          if (result == true && mounted) _loadUserRecipes();
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.withAlpha(26),
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: IconButton(
                                                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                                        padding: const EdgeInsets.all(4),
                                                        constraints: const BoxConstraints(),
                                                        onPressed: () => _confirmDelete(recipe),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
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
                                          ],
                                        ),
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
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: 4,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: textDark),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: textMedium),
        ),
      ],
    );
  }
}