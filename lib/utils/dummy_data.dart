import '../models/recipe_model.dart';
import '../models/category_model.dart';
import '../models/notification_model.dart';

List<Category> dummyCategories = [
  Category(name: 'Breakfast', icon: '🍳', isActive: true),
  Category(name: 'Lunch', icon: '🥗'),
  Category(name: 'Dinner', icon: '🍝'),
  Category(name: 'Snack', icon: '🍿'),
  Category(name: 'Cuisine', icon: '🍜'),
  Category(name: 'Smoothies', icon: '🥤'),
  Category(name: 'Dessert', icon: '🍰'),
  Category(name: 'Pudding', icon: '🍮'),
  Category(name: 'Bread', icon: '🥖'),
  Category(name: 'More', icon: '➕'),
];

List<Recipe> dummyTrendingRecipes = [
  Recipe(
    id: '1',
    title: 'Avocado Toast',
    imageUrl: 'https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?w=500',
    category: 'Breakfast',
    likes: 234,
    isLiked: false, ingredients: [], steps: [],
  ),
  Recipe(
    id: '2',
    title: 'Berry Smoothie Bowl',
    imageUrl: 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500',
    category: 'Smoothies',
    likes: 189,
    isLiked: true, ingredients: [], steps: [],
  ),
  Recipe(
    id: '3',
    title: 'Mushroom Risotto',
    imageUrl: 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=500',
    category: 'Dinner',
    likes: 321,
    isLiked: false, ingredients: [], steps: [],
  ),
  Recipe(
    id: '4',
    title: 'Chocolate Pudding',
    imageUrl: 'https://images.unsplash.com/photo-1541783245831-57f6f6ab557b?w=500',
    category: 'Dessert',
    likes: 445,
    isLiked: false, ingredients: [], steps: [],
  ),
];

List<Recipe> dummyUserRecipes = [
  Recipe(
    id: 'u1',
    title: 'Homemade Pizza',
    imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
    category: 'Dinner',
    likes: 120,
    authorName: 'You', ingredients: [], steps: [],
  ),
  Recipe(
    id: 'u2',
    title: 'Green Salad',
    imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
    category: 'Lunch',
    likes: 87,
    authorName: 'You', ingredients: [], steps: [],
  ),
];

List<Recipe> dummyFavoriteRecipes = [
  Recipe(
    id: 'f1',
    title: 'Berry Smoothie Bowl',
    imageUrl: 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500',
    category: 'Smoothies',
    likes: 189,
    isLiked: true, ingredients: [], steps: [],
  ),
  Recipe(
    id: 'f2',
    title: 'Chocolate Pudding',
    imageUrl: 'https://images.unsplash.com/photo-1541783245831-57f6f6ab557b?w=500',
    category: 'Dessert',
    likes: 445,
    isLiked: true, ingredients: [], steps: [],
  ),
];

List<NotificationItem> dummyNotifications = [
  NotificationItem(id: 'n1', title: 'Like', message: 'Sarah liked your Avocado Toast recipe', timeAgo: '2 hours ago'),
  NotificationItem(id: 'n2', title: 'Comment', message: 'John commented on your Smoothie Bowl', timeAgo: 'Yesterday'),
  NotificationItem(id: 'n3', title: 'New Follower', message: 'Emma started following you', timeAgo: '3 days ago'),
];