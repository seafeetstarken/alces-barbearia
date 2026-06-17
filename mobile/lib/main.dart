import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with the provided URL and Anon Key
  await Supabase.initialize(
    url: 'https://rmcrqaekocvdjmvojyir.supabase.co',
    anonKey: 'sb_publishable_emE7lBZ9Sd15j0yhveaBoA_86hvvOP2',
  );

  runApp(const AlcesApp());
}

class AlcesApp extends StatelessWidget {
  const AlcesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alces Barbearia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
