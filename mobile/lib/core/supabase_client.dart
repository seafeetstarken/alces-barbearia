import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://baafdmeulyzpcgbqqeut.supabase.co';
  static const String anonKey = 'sb_publishable_PPRRbIomSQgpSVNJjWvLWA_vFJMz72l';
}

SupabaseClient get supabase => Supabase.instance.client;
