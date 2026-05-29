# 🍽️ Claude Recipe - Modern Recipe Sharing App

A feature-rich recipe application built with **Flutter** and **Sup abase**. Users can explore, add, like, save, and manage recipes with a modern, responsive UI.

![Flutter](https://img.shields.io/badge/Flutter-3.27+-blue.svg)
![Sup abase](https://img.shields.io/badge/Supabase-2.5.0+-green.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

---

## ✨ Key Features

### 👤 Authentication
- Register / Login with email & password (Sup abase Auth)
- Show/hide password toggle
- Logout with confirmation dialog

### 📝 Recipe Management (CRUD)
- **Create**: Upload image, title, description, category, dynamic ingredients & steps
- **Read**: Detailed recipe page with ingredients, steps, like/save buttons, author info
- **Update**: Edit all recipe data including image
- **Delete**: Confirmation dialog, removes from database & storage

### ❤️ Like & Save (Bookmark)
- Like/unlike recipes (optimistic UI update, database sync)
- Save/unsaved recipes (bookmark)
- **Favorite Screen** – shows all liked recipes
- **Saved Recipes Screen** – shows all bookmarked recipes

### 🔍 Explore & Search
- **Home Screen**: Category grid (icons + names), live search (by title), filter by category
- **Trending Recipe**: 2 rows of horizontal scroll, 5 items each (max 10 total)
- **Explore Screen**: History of viewed recipes (saved when you open recipe detail)

### 👤 User Profile
- Edit display name & profile picture (upload to Sup abase Storage)
- Stats: Recipes count, Followers (dummy), Following (dummy)
- List of user's own recipes with edit/delete buttons
- "Saved" chip button to navigate to Saved Recipes

### 🎨 Modern UI/UX
- **Theme**: Slate blue (#2C3E50), soft background (#F8FAFC), Poppins font
- **Bottom Navigation Bar**: Floating pill-shaped, white background, active icon slate blue
- **Recipe Cards**: Subtle shadow, border radius 16, compact padding
- **Action Chips** (like/save): Border, soft background when active
- **Animations**: Fade-in & slide-up on splash screen, scale animation on like button
- **AppBar**: Transparent with shadow on scroll (ProfileScreen)

### 📦 Backend (Sup abase)
- **Tables**: `recipes` (id, title, image_URL, category, description, ingredients, steps, likes, is_liked, is_saved, author_name, author_avatar, created_at, user_id)
- **History table**: `user_history` (user_id, recipe_id, viewed_at)
- **Storage buckets**: `recipe_images` (recipe images), `avatars` (profile pictures)
- **RLS Policies**: Insert/Select/Update/Delete restricted to authenticated users

---

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.27+ | UI framework |
| Sup abase | 2.5.0 | Backend (Auth, Database, Storage) |
| Google Fonts | 6.1.0 | Poppins typography |
| Image Picker | 1.0.5 | Pick images from gallery |
| Flutter Staggered Grid | 0.7.0 | Masonry grid for Explore screen |

---

## 🚀 How to Run the Project

### 1. Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- A free Sup abase account

### 2. Clone Repository
```bash
git clone https://github.com/yourusername/claude-recipe.git
cd claude-recipe