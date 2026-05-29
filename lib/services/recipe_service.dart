import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';
import 'supabase_service.dart';

class RecipeService {
  final SupabaseClient _client = SupabaseService().client;

  Future<List<Recipe>> fetchAllRecipes() async {
    final response = await _client
        .from('recipes')
        .select()
        .order('created_at', ascending: false);
    return response.map<Recipe>((json) => Recipe.fromJson(json)).toList();
  }

  Future<List<Recipe>> fetchUserRecipes(String userId) async {
    final response = await _client
        .from('recipes')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map<Recipe>((json) => Recipe.fromJson(json)).toList();
  }

  Future<List<Recipe>> fetchFavoriteRecipes() async {
    final response = await _client
        .from('recipes')
        .select()
        .eq('is_liked', true)
        .order('created_at', ascending: false);
    return response.map<Recipe>((json) => Recipe.fromJson(json)).toList();
  }

  Future<List<Recipe>> fetchSavedRecipes() async {
    final response = await _client
        .from('recipes')
        .select()
        .eq('is_saved', true)
        .order('created_at', ascending: false);
    return response.map<Recipe>((json) => Recipe.fromJson(json)).toList();
  }

  Future<String?> uploadImage(File imageFile, String fileName) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return await uploadImageBytes(bytes, fileName);
    } catch (e) {
      print('Upload error (File): $e');
      return null;
    }
  }

  Future<String?> uploadImageBytes(Uint8List bytes, String fileName) async {
    try {
      await _client.storage.from('recipe_images').uploadBinary(
            'public/$fileName',
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      return _client.storage.from('recipe_images').getPublicUrl('public/$fileName');
    } catch (e) {
      print('Upload error (Bytes): $e');
      return null;
    }
  }

  Future<Recipe?> addRecipe(Recipe recipe) async {
    try {
      final response = await _client
          .from('recipes')
          .insert(recipe.toJson())
          .select()
          .single();
      return Recipe.fromJson(response);
    } catch (e) {
      print('Add recipe error: $e');
      return null;
    }
  }

  Future<Recipe?> updateRecipe(Recipe recipe) async {
    try {
      final response = await _client
          .from('recipes')
          .update(recipe.toJson())
          .eq('id', recipe.id)
          .select()
          .single();
      return Recipe.fromJson(response);
    } catch (e) {
      print('Update recipe error: $e');
      return null;
    }
  }

  Future<bool> deleteRecipe(String recipeId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ Delete gagal: User tidak login');
        return false;
      }

      print('🗑️ Mencoba hapus recipe: $recipeId, user_id: ${user.id}');

      final check = await _client
          .from('recipes')
          .select('user_id')
          .eq('id', recipeId)
          .maybeSingle();

      if (check == null) {
        print('❌ Recipe tidak ditemukan');
        return false;
      }

      if (check['user_id'] != user.id) {
        print('❌ Resep bukan milik user ini');
        return false;
      }

      await _client
          .from('recipes')
          .delete()
          .eq('id', recipeId);

      print('✅ Recipe berhasil dihapus');
      return true;
    } catch (e) {
      print('❌ Delete recipe error: $e');
      return false;
    }
  }

  Future<void> toggleLike(String recipeId, bool currentLikeStatus, int currentLikes) async {
    final newLikeStatus = !currentLikeStatus;
    int newLikeCount = newLikeStatus ? currentLikes + 1 : currentLikes - 1;
    if (newLikeCount < 0) newLikeCount = 0;
    await _client
        .from('recipes')
        .update({'is_liked': newLikeStatus, 'likes': newLikeCount})
        .eq('id', recipeId);
  }

  Future<void> toggleSave(String recipeId, bool currentSaveStatus) async {
    final newSaveStatus = !currentSaveStatus;
    await _client
        .from('recipes')
        .update({'is_saved': newSaveStatus})
        .eq('id', recipeId);
  }

  // ==================== HISTORY (EXPLORE) ====================

  Future<void> addToHistory(String recipeId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final now = DateTime.now().toIso8601String();
    await _client.from('user_history').upsert({
      'user_id': user.id,
      'recipe_id': recipeId,
      'viewed_at': now,
    }, onConflict: 'user_id,recipe_id');
  }

  // 🔥 Perbaikan: tambahkan 'description' ke select
  Future<List<Recipe>> fetchHistoryRecipes() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final response = await _client
        .from('user_history')
        .select('''
          recipe_id,
          viewed_at,
          recipes:recipe_id (
            id, title, image_url, category, description, likes, is_liked, is_saved,
            ingredients, steps, author_name, author_avatar, created_at, user_id
          )
        ''')
        .eq('user_id', user.id)
        .order('viewed_at', ascending: false);
    final List<Recipe> recipes = [];
    for (var item in response) {
      final recipeJson = item['recipes'];
      if (recipeJson != null) {
        recipes.add(Recipe.fromJson(recipeJson));
      }
    }
    return recipes;
  }
}