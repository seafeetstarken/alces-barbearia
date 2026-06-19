import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/app_state.dart';
import '../models/appointment.dart';
import '../theme/app_theme.dart';
import '../widgets/alces_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'welcome_screen.dart';

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
            AlcesCard(
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
            
            // Gamification CTA Banner
            AlcesCard(
              border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5), width: 1.5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryGold.withOpacity(0.15), Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, color: AppTheme.primaryGold),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complete seu cadastro!',
                            style: TextStyle(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ganhe 100 AlceCoins agora mesmo e desbloqueie sua primeira conquista no bando.',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppTheme.primaryGold),
                  ],
                ),
              ),
              onTap: () {
                // Future Implementation: Edit Profile Dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edição de perfil será implementada em breve!')),
                );
              },
            ),

            const SizedBox(height: 16),
            ValueListenableBuilder<String?>(
              valueListenable: _appState.activePlan,
              builder: (context, planName, _) {
                final hasActivePlan = planName != null && planName.isNotEmpty;
                return AlcesCard(
                  border: Border.all(
                    color: hasActivePlan
                        ? const Color(0xFF52B788).withOpacity(0.3)
                        : Colors.white.withOpacity(0.06),
                    width: 1.5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF52B788).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF52B788).withOpacity(0.3)),
                          ),
                          child: const Text('Ativo', style: TextStyle(color: Color(0xFF52B788), fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.textMuted.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.textMuted.withOpacity(0.3)),
                          ),
                          child: const Text('Inativo', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
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
                final now = DateTime.now();
                final futureAppointments = list.where((a) => a.date.isAfter(now) || (a.date.day == now.day && a.date.month == now.month && a.date.year == now.year)).toList();
                
                if (futureAppointments.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Nenhum agendamento futuro marcado.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  );
                }

                return Column(
                  children: futureAppointments.map((appt) {
                    final store = _appState.stores.value.where((s) => s.id == appt.storeId).firstOrNull;
                    final service = _appState.services.value.where((s) => s.id == appt.serviceId).firstOrNull;
                    final barber = _appState.barbers.value.where((b) => b.id == appt.barberId).firstOrNull;
                    
                    final dateStr = DateFormat('dd/MM/yyyy').format(appt.date);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AlcesCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service?.name ?? 'Serviço',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Barbeiro: ${barber?.name.split(' ')[0] ?? ''}',
                                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                                      ),
                                      Text(
                                        'Loja: ${store?.name.replaceAll("Alce\'s Barbearia - ", "") ?? ''}',
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD4A03C).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFD4A03C).withOpacity(0.3)),
                                      ),
                                      child: const Text('Agendado', style: TextStyle(color: Color(0xFFD4A03C), fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
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
                            const Divider(color: Colors.white12, height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: () => _appState.cancelAppointment(appt.id),
                                icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                                label: const Text('Cancelar Agendamento', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
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
            ValueListenableBuilder<List<Appointment>>(
              valueListenable: _appState.upcomingAppointments,
              builder: (context, list, _) {
                final now = DateTime.now();
                final pastAppointments = list.where((a) => a.date.isBefore(DateTime(now.year, now.month, now.day))).toList();

                if (pastAppointments.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Nenhum histórico de visitas encontrado.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  );
                }

                return Column(
                  children: pastAppointments.map((appt) {
                    final store = _appState.stores.value.where((s) => s.id == appt.storeId).firstOrNull;
                    final service = _appState.services.value.where((s) => s.id == appt.serviceId).firstOrNull;
                    final barber = _appState.barbers.value.where((b) => b.id == appt.barberId).firstOrNull;
                    final dateStr = DateFormat('dd/MM/yyyy').format(appt.date);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AlcesCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service?.name ?? 'Serviço',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Barbeiro: ${barber?.name.split(' ')[0] ?? ''}', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                                  Text('Loja: ${store?.name.replaceAll("Alce\'s Barbearia - ", "") ?? ''}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Icon(Icons.check_circle, color: Color(0xFF52B788), size: 16),
                                const SizedBox(height: 8),
                                Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
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
            const SizedBox(height: 32),
            AlcesButton(
              text: 'Sair da Conta',
              isPrimary: false,
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
