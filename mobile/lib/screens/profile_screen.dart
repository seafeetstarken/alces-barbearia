import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../data/app_state.dart';
import '../models/appointment.dart';
import '../models/store.dart';
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

  Future<void> _showCompleteProfileDialog() async {
    final emailController = TextEditingController(text: _appState.userEmail);
    final addressController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.backgroundDark,
              title: const Text('Completar Cadastro', style: TextStyle(color: AppTheme.primaryGold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email, color: AppTheme.primaryGold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Data de Nascimento',
                        prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryGold),
                        hintText: selectedDate == null ? 'DD/MM/AAAA' : DateFormat('dd/MM/yyyy').format(selectedDate!),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppTheme.primaryGold,
                                  onPrimary: Colors.black,
                                  surface: AppTheme.backgroundDark,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setDialogState(() => selectedDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Endereço (Opcional)',
                        prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryGold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Complete para ganhar +100 XP e 100 AlceCoins!', 
                      style: TextStyle(color: Color(0xFF52B788), fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
                  onPressed: () async {
                    if (emailController.text.isEmpty || selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('E-mail e Data de Nascimento são obrigatórios!')),
                      );
                      return;
                    }

                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      await Supabase.instance.client.from('profiles').update({
                        'email': emailController.text,
                        'birth_date': selectedDate!.toIso8601String(),
                        'address': addressController.text,
                        'xp': _appState.userXp.value + 100,
                        'alce_coins': _appState.userCoins.value + 100,
                      }).eq('id', user.id);
                      
                      // Refresh app state
                      _appState.userXp.value += 100;
                      _appState.userCoins.value += 100;
                      _appState.userBirthDate.value = selectedDate!.toIso8601String();
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sucesso! +100 XP e 100 AlceCoins recebidos! 🦌🪙'),
                            backgroundColor: Color(0xFF52B788),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Salvar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
                    child: Text(
                      _appState.userName.isNotEmpty ? _appState.userName.substring(0, 2).toUpperCase() : 'US',
                      style: const TextStyle(
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
                          _appState.userEmail.isNotEmpty ? _appState.userEmail : 'Sem e-mail cadastrado',
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
            
            // Gamification Dashboard
            ValueListenableBuilder<int>(
              valueListenable: _appState.userLevel,
              builder: (context, level, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: _appState.userXp,
                  builder: (context, xp, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _appState.userCoins,
                      builder: (context, coins, _) {
                        double progress = xp / (level * 500); // 500 xp per level rule
                        if (progress > 1.0) progress = 1.0;
                        
                        return AlcesCard(
                          border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5), width: 1.5),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.workspace_premium, color: AppTheme.primaryGold, size: 28),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Level $level',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGold.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.monetization_on, color: AppTheme.primaryGold, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$coins Coins',
                                          style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Progresso do Nível', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                  Text('$xp / ${level * 500} XP', style: const TextStyle(color: AppTheme.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGold),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        );
                      }
                    );
                  }
                );
              }
            ),
            const SizedBox(height: 16),
            
            // Gamification CTA Banner (Only show if not complete)
            ValueListenableBuilder<String?>(
              valueListenable: _appState.userBirthDate,
              builder: (context, birthDate, _) {
                if (birthDate != null && birthDate.isNotEmpty) {
                  return const SizedBox.shrink(); // Already completed
                }
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AlcesCard(
                    border: Border.all(color: const Color(0xFF52B788).withOpacity(0.5), width: 1.5),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFF52B788).withOpacity(0.15), Colors.transparent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF52B788).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.star, color: Color(0xFF52B788)),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Complete seu cadastro!',
                                  style: TextStyle(
                                    color: Color(0xFF52B788),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Ganhe 100 AlceCoins agora mesmo e desbloqueie conquistas.',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Color(0xFF52B788)),
                        ],
                      ),
                    ),
                    onTap: _showCompleteProfileDialog,
                  ),
                );
              },
            ),
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
            const SizedBox(height: 16),
            
            // Preferência de Unidade
            ValueListenableBuilder<Store>(
              valueListenable: _appState.activeStore,
              builder: (context, activeStore, _) {
                return AlcesCard(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppTheme.backgroundDark,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selecionar Unidade Preferida',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Selecione qual barbearia ficará salva como sua unidade padrão:',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                              ),
                              const SizedBox(height: 20),
                              ..._appState.stores.value.map((store) {
                                final isSelected = activeStore.id == store.id;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: AlcesCard(
                                    onTap: () {
                                      _appState.changeStore(store);
                                      Navigator.pop(context);
                                    },
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryGold
                                          : Colors.white.withOpacity(0.06),
                                      width: 1.5,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.store, color: AppTheme.primaryGold),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            store.name.replaceAll("Alce's Barbearia - ", ""),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? AppTheme.primaryGold : Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(Icons.check_circle, color: AppTheme.primaryGold),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.place, color: AppTheme.primaryGold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Unidade de Preferência',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeStore.name.replaceAll("Alce's Barbearia - ", ""),
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.primaryGold),
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
