import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/alces_ui.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  void _handleRegister() {
    // TODO: Implement Supabase Auth
    // For MVP UI, just bypass and go to MainScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Criar cadastro', style: TextStyle(color: AppTheme.primaryGold)),
        iconTheme: const IconThemeData(color: AppTheme.primaryGold),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_register.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: AppTheme.backgroundDark.withOpacity(0.92),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Seu nome completo',
                            prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryGold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Phone
                        TextField(
                          controller: _phoneController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Celular (DDD+Nr)',
                            prefixIcon: Icon(Icons.phone_android, color: AppTheme.primaryGold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Email
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail (obrigatório)',
                            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // CPF (Optional)
                        TextField(
                          controller: _cpfController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'CPF (opcional)',
                            prefixIcon: Icon(Icons.credit_card, color: AppTheme.primaryGold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Password (combining the two steps into one for better UX)
                        TextField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.white),
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Sua senha',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGold),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: AppTheme.primaryGold,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Button
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: AlcesButton(
                    text: 'Avançar',
                    isPrimary: true,
                    onPressed: _handleRegister,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
