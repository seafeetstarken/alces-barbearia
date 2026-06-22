import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/alces_ui.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CheckoutCardScreen extends StatefulWidget {
  final double amount;
  final String? description;
  final bool isSubscription;
  final String? planName;
  final String? appointmentId;

  const CheckoutCardScreen({
    super.key,
    required this.amount,
    this.description,
    this.isSubscription = false,
    this.planName,
    this.appointmentId,
  });

  @override
  State<CheckoutCardScreen> createState() => _CheckoutCardScreenState();
}

class _CheckoutCardScreenState extends State<CheckoutCardScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  final _cardNumberMask = MaskTextInputFormatter(mask: '#### #### #### ####', filter: {"#": RegExp(r'[0-9]')});
  final _expiryMask = MaskTextInputFormatter(mask: '##/##', filter: {"#": RegExp(r'[0-9]')});
  final _cvvMask = MaskTextInputFormatter(mask: '####', filter: {"#": RegExp(r'[0-9]')});

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appState = AppState();

      final parts = _expiryController.text.split('/');
      final expiryMonth = parts[0];
      final expiryYear = '20${parts[1]}';

      final creditCard = {
        "holderName": _nameController.text,
        "number": _numberController.text.replaceAll(' ', ''),
        "expiryMonth": expiryMonth,
        "expiryYear": expiryYear,
        "ccv": _cvvController.text,
      };

      final creditCardHolderInfo = {
        "name": _nameController.text,
        "email": appState.userEmail.isNotEmpty ? appState.userEmail : "cliente@email.com",
        "cpfCnpj": "00000000000",
        "postalCode": "89010-000",
        "addressNumber": "100",
        "addressComplement": "",
        "phone": appState.userPhone.isNotEmpty ? appState.userPhone : "47999999999",
      };

      if (widget.isSubscription) {
        await appState.checkoutSubscription(
          planName: widget.planName ?? 'Plano Clube',
          price: widget.amount,
          billingType: 'CREDIT_CARD',
          creditCard: creditCard,
          creditCardHolderInfo: creditCardHolderInfo,
        );
      } else {
        await appState.checkoutSingle(
          amount: widget.amount,
          billingType: 'CREDIT_CARD',
          description: widget.description,
          appointmentId: widget.appointmentId,
          creditCard: creditCard,
          creditCardHolderInfo: creditCardHolderInfo,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Pagamento Aprovado!'),
          backgroundColor: AppTheme.primaryGold,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro no pagamento: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pagamento via Cartão', style: TextStyle(color: AppTheme.primaryGold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGold),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AlcesCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total a pagar:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text(
                      'R\$ ${widget.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(color: AppTheme.primaryGold, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Text('Dados do Cartão', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _numberController,
                label: 'Número do Cartão',
                icon: Icons.credit_card,
                formatter: _cardNumberMask,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.length < 19 ? 'Cartão inválido' : null,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _nameController,
                label: 'Nome Impresso no Cartão',
                icon: Icons.person_outline,
                keyboardType: TextInputType.name,
                validator: (val) => val == null || val.isEmpty ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _expiryController,
                      label: 'Validade (MM/AA)',
                      icon: Icons.calendar_today,
                      formatter: _expiryMask,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.length < 5 ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _cvvController,
                      label: 'CVC',
                      icon: Icons.security,
                      formatter: _cvvMask,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.length < 3 ? 'Inválido' : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('CONFIRMAR PAGAMENTO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputFormatter? formatter,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      inputFormatters: formatter != null ? [formatter] : [],
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryGold),
        ),
      ),
    );
  }
}
