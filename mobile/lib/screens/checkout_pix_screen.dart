import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _generatePixCharge();
  }

  Future<void> _generatePixCharge() async {
    try {
      // MOCK PARA TESTFLIGHT: Bypass Asaas call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _paymentData = {
          'encodedImage': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=', // Black pixel
          'payload': '00020101021126580014br.gov.bcb.pix0136123e4567-e89b-12d3-a456-426655440000520400005303986540510.005802BR5915Alces Barbearia6009Sao Paulo62070503***63041A2B',
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pagamento via PIX', style: TextStyle(color: AppTheme.primaryGold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGold),
          onPressed: () => Navigator.pop(context, true), // Retorna indicando que tentou/concluiu
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
