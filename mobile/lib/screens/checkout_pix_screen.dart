import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/alces_ui.dart';

class CheckoutPixScreen extends StatefulWidget {
  final double amount;
  final String? description;
  final bool isSubscription;
  final String? planName;
  final String? appointmentId;

  const CheckoutPixScreen({
    super.key,
    required this.amount,
    this.description,
    this.isSubscription = false,
    this.planName,
    this.appointmentId,
  });

  @override
  State<CheckoutPixScreen> createState() => _CheckoutPixScreenState();
}

class _CheckoutPixScreenState extends State<CheckoutPixScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _paymentData;
  Timer? _statusTimer;
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _generatePixCharge();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _generatePixCharge() async {
    try {
      final appState = AppState();
      final Map<String, dynamic> result;

      if (widget.isSubscription) {
        result = await appState.checkoutSubscription(
          planName: widget.planName ?? 'Plano Clube',
          price: widget.amount,
          billingType: 'PIX',
        );
      } else {
        result = await appState.checkoutSingle(
          amount: widget.amount,
          billingType: 'PIX',
          appointmentId: widget.appointmentId,
          description: widget.description ?? "Agendamento - Alce's Barbearia",
        );
      }

      setState(() {
        _paymentData = {
          'encodedImage': result['pixQrCode']?['encodedImage'],
          'payload': result['pixQrCode']?['payload'] ?? result['invoiceUrl'],
          'invoiceUrl': result['invoiceUrl'],
          'paymentId': result['id'],
        };
        _isLoading = false;
      });

      _startPolling();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;

      if (widget.isSubscription) {
        final res = await client
            .from('profiles')
            .select('active_subscription_status, xp, alce_coins')
            .eq('id', user.id)
            .maybeSingle();
        if (res != null && res['active_subscription_status'] == 'ACTIVE') {
          _statusTimer?.cancel();
          final appState = AppState();
          appState.userXp.value = res['xp'] ?? 0;
          appState.userCoins.value = res['alce_coins'] ?? 0;
          appState.selectPlan(widget.planName);
          setState(() {
            _isPaid = true;
          });
        }
      } else {
        if (widget.appointmentId == null) return;
        final res = await client
            .from('appointments')
            .select('payment_status')
            .eq('id', widget.appointmentId!)
            .maybeSingle();
        if (res != null && (res['payment_status'] == 'PAID' || res['payment_status'] == 'RECEIVED')) {
          _statusTimer?.cancel();
          final profileRes = await client
              .from('profiles')
              .select('xp, alce_coins')
              .eq('id', user.id)
              .maybeSingle();
          if (profileRes != null) {
            final appState = AppState();
            appState.userXp.value = profileRes['xp'] ?? 0;
            appState.userCoins.value = profileRes['alce_coins'] ?? 0;
          }
          setState(() {
            _isPaid = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking payment status: $e');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código PIX copiado!'),
        backgroundColor: AppTheme.primaryGold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isPaid) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF52B788),
                  size: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pagamento Confirmado!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.isSubscription
                      ? 'Sua assinatura do plano "${widget.planName}" foi ativada com sucesso no Clube Alce\'s!'
                      : 'Seu agendamento na unidade Escola Agrícola foi confirmado com sucesso.',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AlcesCard(
                  child: Column(
                    children: [
                      const Text(
                        'Recompensas Recebidas',
                        style: TextStyle(
                          color: AppTheme.primaryGold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                widget.isSubscription ? '+100' : '+50',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('XP', style: TextStyle(color: AppTheme.textMuted)),
                            ],
                          ),
                          Container(width: 1, height: 40, color: Colors.white12),
                          Column(
                            children: [
                              Text(
                                widget.isSubscription ? '+30' : '+10',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('AlceCoins', style: TextStyle(color: AppTheme.textMuted)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'EXCELENTE',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pagamento via PIX', style: TextStyle(color: AppTheme.primaryGold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGold),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
          : _error != null
              ? Center(child: Text('Erro: $_error', style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AlcesCard(
                        child: Column(
                          children: [
                            const Text(
                              'Valor a pagar',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'R\$ ${widget.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: const TextStyle(
                                color: AppTheme.primaryGold,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_paymentData?['encodedImage'] != null)
                        Center(
                          child: Container(
                            width: 250,
                            height: 250,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.memory(
                              base64Decode(_paymentData!['encodedImage']),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (_paymentData?['payload'] != null) ...[
                        const Text(
                          'PIX Copia e Cola',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            _paymentData!['payload'],
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(_paymentData!['payload']),
                          icon: const Icon(Icons.copy, color: Colors.black),
                          label: const Text('COPIAR CÓDIGO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGold,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      const Text(
                        'Após o pagamento, o sistema identificará automaticamente em até 5 minutos.',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('JÁ PAGUEI / VOLTAR', style: TextStyle(color: AppTheme.primaryGold)),
                      ),
                    ],
                  ),
                ),
    );
  }
}
