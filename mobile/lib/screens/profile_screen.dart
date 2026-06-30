import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../data/app_state.dart';
import '../models/appointment.dart';
import '../models/store.dart';
import '../models/user_role.dart';
import '../models/barber.dart';
import '../theme/app_theme.dart';
import '../widgets/alces_ui.dart';
import 'gamification_info_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'welcome_screen.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppState _appState = AppState();
  List<Appointment> _barberUpcomingAppointments = [];
  bool _isLoadingBarberAppointments = false;

  @override
  void initState() {
    super.initState();
    _loadBarberAppointmentsIfNeeded();
  }

  Future<void> _loadBarberAppointmentsIfNeeded() async {
    final isBarber = _appState.userRole.value == UserRole.barber;
    if (!isBarber) return;

    final barber = _appState.linkedBarber.value;
    if (barber == null) return;

    if (mounted) {
      setState(() => _isLoadingBarberAppointments = true);
    }
    try {
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      
      final response = await Supabase.instance.client
          .from('appointments')
          .select('*, profiles(full_name, phone)')
          .eq('barber_id', barber.id)
          .neq('status', 'cancelled')
          .gte('appointment_date', todayStr)
          .order('appointment_date', ascending: true)
          .order('appointment_time', ascending: true);

      final appointments = (response as List).map((data) {
        final profile = data['profiles'] as Map<String, dynamic>?;
        final resolvedClientName = data['client_name'] as String? ?? 
            profile?['full_name'] as String? ?? 
            'Cliente';
        
        return Appointment(
          id: data['id'] as String,
          userId: data['user_id'] as String?,
          storeId: data['store_id'] as String,
          barberId: data['barber_id'] as String,
          serviceId: data['service_id'] as String,
          date: DateTime.parse(data['appointment_date'] as String),
          time: data['appointment_time'] as String,
          clientName: resolvedClientName,
          status: data['status'] as String? ?? 'Agendado',
        );
      }).toList();

      final futureAppointments = appointments.where((appt) {
        if (appt.date.year == now.year && appt.date.month == now.month && appt.date.day == now.day) {
          try {
            final apptTimeParts = appt.time.split(':');
            final apptHour = int.parse(apptTimeParts[0]);
            final apptMinute = int.parse(apptTimeParts[1]);
            final nowHour = now.hour;
            final nowMinute = now.minute;
            if (apptHour < nowHour) return false;
            if (apptHour == nowHour && apptMinute < nowMinute) return false;
          } catch (_) {}
        }
        return true;
      }).toList();

      if (mounted) {
        setState(() {
          _barberUpcomingAppointments = futureAppointments;
          _isLoadingBarberAppointments = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar agendamentos do barbeiro: $e');
      if (mounted) {
        setState(() => _isLoadingBarberAppointments = false);
      }
    }
  }

  Future<void> _showCompleteProfileDialog() async {
    final addressController = TextEditingController();
    final dateController = TextEditingController();
    
    final dateFormatter = MaskTextInputFormatter(
      mask: '##/##/####', 
      filter: { "#": RegExp(r'[0-9]') },
      type: MaskAutoCompletionType.lazy
    );

    // If birth date is already saved, prefill it
    if (_appState.userBirthDate.value != null) {
      try {
        final date = DateTime.parse(_appState.userBirthDate.value!);
        dateController.text = DateFormat('dd/MM/yyyy').format(date);
      } catch (_) {}
    }

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
                      controller: dateController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [dateFormatter],
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Data de Nascimento',
                        prefixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryGold),
                        hintText: 'DD/MM/AAAA',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Endereço (Opcional)',
                        prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryGold),
                        hintText: 'Digite o nome da rua',
                      ),
                      // TODO: Integrar Google Places API aqui
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
                    if (dateController.text.length < 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data de Nascimento válida é obrigatória!')),
                      );
                      return;
                    }

                    // Parse the date DD/MM/YYYY to DateTime
                    final parts = dateController.text.split('/');
                    final parsedDate = DateTime(
                      int.parse(parts[2]),
                      int.parse(parts[1]),
                      int.parse(parts[0]),
                    );

                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      await Supabase.instance.client.from('profiles').update({
                        'birth_date': parsedDate.toIso8601String(),
                        'address': addressController.text,
                        'xp': _appState.userXp.value + 100,
                        'alce_coins': _appState.userCoins.value + 100,
                      }).eq('id', user.id);
                      
                      // Refresh app state
                      _appState.userXp.value += 100;
                      _appState.userCoins.value += 100;
                      _appState.userBirthDate.value = parsedDate.toIso8601String();
                      
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
    return ValueListenableBuilder<UserRole>(
      valueListenable: _appState.userRole,
      builder: (context, role, _) {
        return ValueListenableBuilder<Barber?>(
          valueListenable: _appState.linkedBarber,
          builder: (context, barber, _) {
            final isBarber = role == UserRole.barber;
            final displayName = isBarber 
                ? (barber?.name ?? _appState.userName)
                : _appState.userName;

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
                      displayName.isNotEmpty ? displayName.substring(0, 2).toUpperCase() : 'US',
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
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder<String?>(
                          valueListenable: _appState.userSavedEmail,
                          builder: (context, savedEmail, _) {
                            final displayEmail = (savedEmail != null && savedEmail.isNotEmpty) 
                                ? savedEmail 
                                : 'Sem e-mail cadastrado';
                            return Text(
                              displayEmail,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                            );
                          }
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _appState.userPhone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        if (isBarber) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3), width: 1),
                            ),
                            child: const Text(
                              'Profissional',
                              style: TextStyle(
                                color: AppTheme.primaryGold,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Barber Stats Card (If barber)
            if (isBarber) _buildBarberStatsCard(),

            if (!isBarber) ...[
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const GamificationInfoScreen()),
                              );
                            },
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
            ],

            // Admin Section
            ValueListenableBuilder<bool>(
              valueListenable: _appState.isAdmin,
              builder: (context, isAdmin, _) {
                if (!isAdmin) return const SizedBox.shrink();
                
                return Column(
                  children: [
                    AlcesCard(
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.admin_panel_settings, color: Colors.redAccent),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Painel Administrativo',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Gerenciar clientes e assinaturas',
                                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.redAccent),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                );
              },
            ),

            // Upcoming appointments section
            Text(
              'Próximos Agendamentos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            isBarber
                ? _buildBarberUpcomingAppointments()
                : _buildClientUpcomingAppointments(),
            const SizedBox(height: 28),

            if (!isBarber) ...[
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
            ],
            
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
          },
        );
      },
    );
  }

  Widget _buildClientUpcomingAppointments() {
    return ValueListenableBuilder<List<Appointment>>(
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
    );
  }

  Widget _buildBarberUpcomingAppointments() {
    if (_isLoadingBarberAppointments) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGold),
        ),
      );
    }

    if (_barberUpcomingAppointments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Nenhum agendamento futuro marcado.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
      );
    }

    return Column(
      children: _barberUpcomingAppointments.map((appt) {
        final store = _appState.stores.value.where((s) => s.id == appt.storeId).firstOrNull;
        final service = _appState.services.value.where((s) => s.id == appt.serviceId).firstOrNull;
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
                            'Cliente: ${appt.clientName ?? 'Walk-in'}',
                            style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
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
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.backgroundDark,
                          title: const Text('Cancelar Agendamento', style: TextStyle(color: Colors.white)),
                          content: const Text('Tem certeza que deseja cancelar este agendamento?', style: TextStyle(color: AppTheme.textMuted)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Não', style: TextStyle(color: AppTheme.textMuted)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sim, Cancelar', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _appState.cancelAppointment(appt.id);
                        _loadBarberAppointmentsIfNeeded();
                      }
                    },
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
  }

  Widget _buildBarberStatsCard() {
    final barber = _appState.linkedBarber.value;
    final store = _appState.stores.value.firstWhereOrNull((s) => s.id == barber?.storeId);
    final storeName = store?.name.replaceAll("Alce's Barbearia - ", "") ?? 'Unidade Principal';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AlcesCard(
          border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3), width: 1.5),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_outlined, color: AppTheme.primaryGold, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Desempenho Profissional',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('Unidade', storeName, Icons.store),
                  _buildStatItem('Status', 'Ativo', Icons.check_circle_outline, color: Colors.green),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('Atendimentos (Mês)', '0', Icons.people_outline),
                  _buildStatItem('Faturamento Estimado', 'R\$ 0,00', Icons.monetization_on_outlined, color: AppTheme.primaryGold),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color ?? AppTheme.textMuted, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color ?? Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
