import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/mock_data.dart';
import '../models/plan.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_widgets.dart';

class ClubScreen extends StatefulWidget {
  const ClubScreen({super.key});

  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  final AppState _appState = AppState();
  String _selectedPaymentMethod = 'pix';

  void _showCheckoutSheet(BuildContext context, SubscriptionPlan plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                24,
                16,
                MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Text(
                        'Confirmar Assinatura',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  CardShell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppTheme.primaryGold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plan.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'R\$ ${plan.price.toStringAsFixed(2).replaceAll('.', ',')}/mês',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Forma de Pagamento',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Payment selector
                  Row(
                    children: [
                      Expanded(
                        child: CardShell(
                          onTap: () => setModalState(() => _selectedPaymentMethod = 'pix'),
                          border: Border.all(
                            color: _selectedPaymentMethod == 'pix'
                                ? AppTheme.primaryGold
                                : Colors.white.withOpacity(0.06),
                            width: 1.5,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.pix,
                                color: _selectedPaymentMethod == 'pix'
                                    ? AppTheme.primaryGold
                                    : AppTheme.textMuted,
                              ),
                              const SizedBox(height: 6),
                              const Text('Pix', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const Text('Recomendado', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CardShell(
                          onTap: () => setModalState(() => _selectedPaymentMethod = 'card'),
                          border: Border.all(
                            color: _selectedPaymentMethod == 'card'
                                ? AppTheme.primaryGold
                                : Colors.white.withOpacity(0.06),
                            width: 1.5,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.credit_card,
                                color: _selectedPaymentMethod == 'card'
                                    ? AppTheme.primaryGold
                                    : AppTheme.textMuted,
                              ),
                              const SizedBox(height: 6),
                              const Text('Cartão', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const Text('Recorrente', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Assinar Agora',
                    onPressed: () {
                      _appState.selectPlan(plan.name);
                      Navigator.pop(context);
                      _showSuccessDialog(context, plan);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFF1B4332),
                child: Icon(Icons.check, color: Color(0xFF52B788), size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'Bem-vindo ao Clube Alce\'s!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Sua assinatura do ${plan.name} foi ativada com sucesso.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Aproveitar Benefícios',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clube Alce\'s'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<String?>(
        valueListenable: _appState.activePlan,
        builder: (context, activePlan, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Club Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.star, color: AppTheme.primaryGold, size: 40),
                      const SizedBox(height: 12),
                      const Text(
                        'Assinatura de Penteado & Estilo',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Corte com facilidade, economize no mês e tenha regalias exclusivas na Alce\'s.',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  activePlan != null ? 'Sua Assinatura Atual' : 'Nossos Planos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 16),

                // Map plans
                ...MockData.plans.map((plan) {
                  final isCurrentPlan = activePlan == plan.name;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CardShell(
                      border: Border.all(
                        color: isCurrentPlan
                            ? const Color(0xFF52B788)
                            : Colors.white.withOpacity(0.06),
                        width: 1.5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.between,
                            children: [
                              Text(
                                plan.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (isCurrentPlan)
                                StatusBadge.success(text: 'Ativo')
                              else
                                Text(
                                  'R\$ ${plan.price.toStringAsFixed(2).replaceAll('.', ',')}/mês',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGold,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.description,
                            style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white12),
                          const SizedBox(height: 12),
                          ...plan.features.map((feature) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.check, color: AppTheme.primaryGold, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          if (!isCurrentPlan)
                            PrimaryButton(
                              text: 'Assinar ${plan.name}',
                              onPressed: activePlan != null
                                  ? null // Disable if they already have another plan (can only have one)
                                  : () => _showCheckoutSheet(context, plan),
                            )
                          else
                            SecondaryButton(
                              text: 'Cancelar Assinatura',
                              onPressed: () {
                                _appState.selectPlan(''); // Reset active plan
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Assinatura cancelada com sucesso.'),
                                    backgroundColor: AppTheme.cardDark,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
