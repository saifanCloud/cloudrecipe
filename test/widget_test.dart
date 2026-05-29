import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_second_app/screens/home_screen.dart';
// Jika nanti butuh provider, bisa ditambahkan seperti ini:
// import 'package:provider/provider.dart';
// import 'package:my_second_app/providers/recipe_provider.dart';

void main() {
  testWidgets('HomeScreen menampilkan komponen utama', (tester) async {
    // Bangun HomeScreen (tanpa provider karena masih dummy data)
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // 1. Verifikasi teks "What's cooking today?" muncul
    expect(find.text("What's cooking today?"), findsOneWidget);

    // 2. Verifikasi search bar dengan hint "Search any recipe..."
    expect(find.text("Search any recipe..."), findsOneWidget);

    // 3. Verifikasi kategori "Breakfast" ada (jika ada di dummy data)
    expect(find.text("Breakfast"), findsOneWidget);

    // 4. Verifikasi trending recipe "Avocado Salad" muncul
    expect(find.text("Avocado Salad"), findsOneWidget);

    // 5. Pastikan bottom navigation tidak ada di layar ini (karena HomeScreen bukan MainScreen)
    expect(find.byIcon(Icons.home_rounded), findsNothing);
  });

  testWidgets('Tombol notifikasi menavigasi ke NotificationScreen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Tap ikon notifikasi
    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    // Setelah navigasi, harus muncul halaman notifikasi
    expect(find.text('Notifications'), findsOneWidget);
  });
}