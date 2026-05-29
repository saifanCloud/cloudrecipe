import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../utils/app_colors.dart';
import 'like_button.dart';

class TrendingRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onLike;
  final VoidCallback? onTap;

  const TrendingRecipeCard({
    super.key,
    required this.recipe,
    required this.onLike,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
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
                      color: AppColors.lightGrey,
                      child: const Icon(Icons.broken_image, size: 40, color: AppColors.mediumGrey),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: LikeButton(
                    isLiked: recipe.isLiked,
                    likeCount: recipe.likes,
                    onTap: onLike,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.category,
                    style: const TextStyle(fontSize: 12, color: AppColors.mediumGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}