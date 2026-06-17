import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/app_state.dart';
import '../data/mock_data.dart';
import '../models/appointment.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile header details
            CardShell(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryGold.withOpacity(0.12),
                    child: const Text(
                      'JS',
                      style: TextStyle(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appState.userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _appState.userEmail,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _appState.userPhone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Active Club Status Block
            ValueListenableBuilder<String?>(
              valueListenable: _appState.activePlan,
              builder: (context, planName, _) {
                final hasActivePlan = planName != null && planName.isNotEmpty;
                return CardShell(
                  border: Border.all(
                    color: hasActivePlan
                        ? const Color(0xFF52B788).withOpacity(0.3)
                        : Colors.white.withOpacity(0.06),
                    width: 1.5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hasActivePlan ? Icons.verified : Icons.star_border,
                            color: hasActivePlan
                                ? const Color(0xFF52B788)
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Clube Alce\'s',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasActivePlan ? planName : 'Nenhuma assinatura ativa',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (hasActivePlan)
                        StatusBadge.success(text: 'Ativo')
                      else
                        StatusBadge.info(text: 'Inativo'),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Upcoming appointments section
            Text(
              'Próximos Agendamentos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<Appointment>>(
              valueListenable: _appState.upcomingAppointments,
              builder: (context, list, _) {
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Nenhum agendamento futuro marcado.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  );
                }

                return Column(
                  children: list.map((appt) {
                    final store = MockData.stores.firstWhere((s) => s.id == appt.storeId);
                    final service = MockData.services.firstWhere((s) => s.id == appt.serviceId);
                    final barber = MockData.barbers.firstWhere((b) => b.id == appt.barberId);
                    
                    final dateStr = DateFormat('dd/MM/yyyy').format(appt.date);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CardShell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Barbeiro: ${barber.name.split(' ')[0]}',
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                                  ),
                                  Text(
                                    'Loja: ${store.name.replaceAll("Alce\'s Barbearia - ", "")}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                StatusBadge.warning(text: 'Agendado'),
                                const SizedBox(height: 8),
                                Text(
                                  '$dateStr às ${appt.time}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppTheme.primaryGold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 28),

            // Past visits history section
            Text(
              'Histórico de Visitas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            Column(
              children: MockData.pastAppointments.map((appt) {
                final store = MockData.stores.firstWhere((s) => s.id == appt.storeId);
                final service = MockData.services.firstWhere((s) => s.id == appt.serviceId);
                final barber = MockData.barbers.firstWhere((b) => b.id == appt.barberId);
                
                final dateStr = DateFormat('dd/MM/yyyy').format(appt.date);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CardShell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Barbeiro: ${barber.name.split(' ')[0]}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                              Text(
                                'Unidade: ${store.name.replaceAll("Alce\'s Barbearia - ", "")}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StatusBadge.info(text: 'Realizado'),
                            const SizedBox(height: 8),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
