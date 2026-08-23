import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static bool get isInitialized {
    try {
      // Accessing the client will throw if Supabase has not been initialized.
      final _ = Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }
}
