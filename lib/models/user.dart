import 'recipe_model.dart';

class User {
  final String name;
  final String avatarUrl;
  final List<Recipe> myRecipes;

  User({required this.name, required this.avatarUrl, required this.myRecipes});
}