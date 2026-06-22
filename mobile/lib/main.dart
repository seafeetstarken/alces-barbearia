import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

bool _supabaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://baafdmeulyzpcgbqqeut.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJhYWZkbWV1bHl6cGNnYnFxZXV0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE3NDMyNzgsImV4cCI6MjA5NzMxOTI3OH0.cycNHV-8ckDsaM6IC4TeFnTqN9-fnCUFcOsKVN86cME',
    );
    _supabaseInitialized = true;
  } catch (e, stack) {
    print('Error initializing Supabase: $e');
    print(stack);
  }

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
      home: _supabaseInitialized
          ? (Supabase.instance.client.auth.currentSession != null
              ? const MainScreen()
              : const WelcomeScreen())
          : const Scaffold(body: Center(child: Text('Erro ao iniciar Supabase. Veja o console.'))),
    );
  }
}
