import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/dummy_data.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna konsisten dengan tema
    const primaryColor = Color(0xFF2C3E50);
    const lightBg = Color(0xFFF8FAFC);
    const textDark = Color(0xFF1E293B);
    const textMedium = Color(0xFF64748B);
    const cardWhite = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: dummyNotifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 60, color: textMedium.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    "No notifications yet",
                    style: GoogleFonts.poppins(fontSize: 16, color: textMedium),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "When someone likes or comments on your recipe,\nit will appear here.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 13, color: textMedium),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: dummyNotifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = dummyNotifications[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon notifikasi (warna sesuai tipe)
                      CircleAvatar(
                        backgroundColor: notif.title == 'Like'
                            ? Colors.red.withValues(alpha: 0.1)
                            : primaryColor.withValues(alpha: 0.1),
                        child: Icon(
                          notif.title == 'Like' ? Icons.favorite : Icons.comment,
                          color: notif.title == 'Like' ? Colors.red : primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Konten
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif.title,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.message,
                              style: GoogleFonts.poppins(fontSize: 13, color: textMedium),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Waktu
                      Text(
                        notif.timeAgo,
                        style: GoogleFonts.poppins(fontSize: 11, color: textMedium),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}