import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/alces_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final cpf = _cpfController.text.replaceAll('.', '').replaceAll('-', '').trim();
    final password = _passwordController.text.trim();
    
    if (name.isEmpty || email.isEmpty || phone.isEmpty || cpf.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (cpf.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CPF inválido. Digite os 11 números.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'phone': phone,
          'cpf': cpf,
        }
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar conta.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nome completo',
                            prefixIcon: Icon(Icons.person, color: AppTheme.primaryGold),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail real',
                            prefixIcon: Icon(Icons.email, color: AppTheme.primaryGold),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Phone
                        TextField(
                          controller: _phoneController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Whatsapp (DDD+Número)',
                            prefixIcon: Icon(Icons.phone_android, color: AppTheme.primaryGold),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // CPF
                        TextField(
                          controller: _cpfController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          inputFormatters: [_cpfFormatter],
                          decoration: const InputDecoration(
                            labelText: 'CPF (apenas números)',
                            prefixIcon: Icon(Icons.badge, color: AppTheme.primaryGold),
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
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleRegister,
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
