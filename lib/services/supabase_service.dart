import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://zzcdpkbboyyrgcajtpvt.supabase.co', // ganti dengan URL Anda
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6Y2Rwa2Jib3l5cmdjYWp0cHZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3NjgwMzAsImV4cCI6MjA5NTM0NDAzMH0.ZSjewF20uqEUYjUmNUcCF8SaXjLFUYPZXK_EjxPgIME', // ganti dengan anon key Anda
    );
  }

  SupabaseClient get client => Supabase.instance.client;
}