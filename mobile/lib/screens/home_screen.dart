import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_state.dart';
import '../models/store.dart';
import '../models/user_role.dart';
import '../models/barber_appointment_view.dart';
import '../theme/app_theme.dart';
import '../widgets/alces_ui.dart';
import 'main_screen.dart';
import 'products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppState _appState = AppState();

  void _showStoreSelector(BuildContext context) {
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
              Text(
                'Selecione a Unidade',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha qual unidade deseja visualizar hoje:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ..._appState.stores.value.map((store) {
                return ValueListenableBuilder<Store>(
                  valueListenable: _appState.activeStore,
                  builder: (context, activeStore, _) {
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
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryGold.withOpacity(0.1)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.store,
                                color: isSelected
                                    ? AppTheme.primaryGold
                                    : AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store.name.replaceAll("Alce's Barbearia - ", ""),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected ? AppTheme.primaryGold : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          store.address.split(',')[0],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textMuted,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.map_outlined, size: 16, color: AppTheme.primaryGold),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Ver no Mapa',
                                        onPressed: () async {
                                          final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(store.address)}');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryGold,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGold.withOpacity(0.08),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          SafeArea(
            child: ValueListenableBuilder<Store>(
              valueListenable: _appState.activeStore,
              builder: (context, currentStore, _) {
                // Get barbers for this store
                final storeBarbers = _appState.barbers.value
                    .where((b) => b.storeId == currentStore.id && b.isActive)
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // App Bar Header (Brand + Store Selector)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                width: 28,
                                height: 28,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.offline_bolt_outlined,
                                  color: AppTheme.primaryGold,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Alce's",
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'BARBEARIA',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 4,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Store Selector Button
                      InkWell(
                        onTap: () => _showStoreSelector(context),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.06)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.place,
                                  color: AppTheme.primaryGold, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                currentStore.name.replaceAll(
                                    "Alce's Barbearia - ", ""),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: AppTheme.primaryGold, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ].animate(interval: 100.ms).fade(duration: 500.ms).slideY(begin: -0.2),
                  ),
                  const SizedBox(height: 16),

                  // Welcome Card & Cashback Info
                  ValueListenableBuilder<UserRole>(
                    valueListenable: _appState.userRole,
                    builder: (context, role, _) {
                      final isBarber = role == UserRole.barber;
                      final barber = _appState.linkedBarber.value;
                      
                      String initials = 'US';
                      if (isBarber && barber != null) {
                        initials = barber.initials;
                      } else if (_appState.userName.isNotEmpty) {
                        final parts = _appState.userName.split(' ');
                        initials = parts.length > 1 
                            ? (parts[0][0] + parts[1][0]).toUpperCase()
                            : parts[0][0].toUpperCase();
                      }

                      return AlcesCard(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppTheme.primaryGold.withOpacity(0.12),
                              child: Text(
                                initials,
                                style: const TextStyle(
                                    color: AppTheme.primaryGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isBarber 
                                        ? 'Olá, ${barber?.name ?? _appState.userName}!'
                                        : 'Olá, ${_appState.userName}!',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (isBarber)
                                    Row(
                                      children: [
                                        const Icon(Icons.cut, color: AppTheme.primaryGold, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Barbeiro • ${currentStore.name.replaceAll("Alce\'s Barbearia - ", "")}',
                                          style: const TextStyle(
                                            color: AppTheme.primaryGold,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    ValueListenableBuilder<int>(
                                      valueListenable: _appState.userLevel,
                                      builder: (context, level, _) {
                                        return ValueListenableBuilder<int>(
                                          valueListenable: _appState.userXp,
                                          builder: (context, xp, _) {
                                            return ValueListenableBuilder<int>(
                                              valueListenable: _appState.userCoins,
                                              builder: (context, coins, _) {
                                                return Row(
                                                  children: [
                                                    const Icon(Icons.workspace_premium, color: Color(0xFF52B788), size: 14),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        'Alces Games • Lvl $level • $xp XP • $coins Coins',
                                                        style: const TextStyle(
                                                          color: Color(0xFF52B788),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            );
                                          }
                                        );
                                      }
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  ).animate().fade(duration: 600.ms).scale(begin: const Offset(0.95, 0.95)),
                  const SizedBox(height: 20),
                  // Club Banner Promo / Barber Today Summary
                  ValueListenableBuilder<UserRole>(
                    valueListenable: _appState.userRole,
                    builder: (context, role, _) {
                      if (role == UserRole.barber) {
                        final barber = _appState.linkedBarber.value;
                        if (barber == null) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<int>(
                              future: _appState.barberRepo.countTodayAppointments(barber.id),
                              builder: (context, snapshot) {
                                final count = snapshot.data ?? 0;
                                return AlcesCard(
                                  padding: const EdgeInsets.all(20),
                                  border: Border.all(
                                    color: AppTheme.primaryGold.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: const [
                                          Text(
                                            'AGENDA DE HOJE',
                                            style: TextStyle(
                                              color: AppTheme.primaryGold,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                              fontSize: 11,
                                            ),
                                          ),
                                          Icon(
                                            Icons.calendar_today,
                                            color: AppTheme.primaryGold,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        count == 0 
                                            ? 'Nenhum agendamento para hoje'
                                            : count == 1 
                                                ? 'Você tem 1 agendamento hoje'
                                                : 'Você tem $count agendamentos hoje',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Gerencie seus horários e atualize o status dos atendimentos diretamente pela agenda.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      AlcesButton(
                                        text: 'Ver Agenda do Dia',
                                        isPrimary: true,
                                        onPressed: () {
                                          final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                                          if (mainScreenState != null) {
                                            mainScreenState.changeTab(2); // 2 is Minha Agenda for barber
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            FutureBuilder<BarberAppointmentView?>(
                              future: _appState.barberRepo.fetchNextAppointment(barber.id),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const AlcesCard(
                                    child: Center(
                                      child: CircularProgressIndicator(color: AppTheme.primaryGold),
                                    ),
                                  );
                                }
                                final nextAppt = snapshot.data;
                                if (nextAppt == null) {
                                  return const SizedBox.shrink();
                                }

                                return AlcesCard(
                                  padding: const EdgeInsets.all(16),
                                  onTap: () {
                                    final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                                    if (mainScreenState != null) {
                                      mainScreenState.changeTab(2); // 2 is Minha Agenda for barber
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'PRÓXIMO CLIENTE',
                                            style: TextStyle(
                                              color: Color(0xFF52B788),
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                              fontSize: 11,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF52B788).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              nextAppt.time,
                                              style: const TextStyle(
                                                color: Color(0xFF52B788),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        nextAppt.clientName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${nextAppt.serviceName} • ${nextAppt.durationMinutes} min',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }

                      // Se for cliente, exibe o banner do Clube Alce's:
                      return ValueListenableBuilder<String?>(
                        valueListenable: _appState.activePlan,
                        builder: (context, planName, _) {
                          final hasActivePlan = planName != null;
                          return AlcesCard(
                            padding: const EdgeInsets.all(20),
                            border: Border.all(
                              color: hasActivePlan
                                  ? const Color(0xFF52B788).withOpacity(0.3)
                                  : AppTheme.primaryGold.withOpacity(0.3),
                              width: 1.5,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      hasActivePlan ? 'CLUBE ATIVO' : 'CLUBE ALCE\'S',
                                      style: TextStyle(
                                        color: hasActivePlan
                                            ? const Color(0xFF52B788)
                                            : AppTheme.primaryGold,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Icon(
                                      hasActivePlan ? Icons.verified : Icons.star,
                                      color: hasActivePlan
                                          ? const Color(0xFF52B788)
                                          : AppTheme.primaryGold,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  hasActivePlan
                                      ? 'Assinatura: $planName'
                                      : 'Corte o cabelo ilimitado no mês',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hasActivePlan
                                      ? 'Sua próxima cobrança ocorrerá automaticamente.'
                                      : 'A partir de R\$ 89,90/mês. Faça parte do nosso clube de assinatura.',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AlcesButton(
                                  text: hasActivePlan ? 'Gerenciar Assinatura' : 'Conhecer Planos',
                                  isPrimary: true,
                                  onPressed: () {
                                    final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                                    if (mainScreenState != null) {
                                      mainScreenState.changeTab(3); // 3 is Club tab
                                    }
                                  },
                                ),
                              ],
                            ),
                          ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 3.seconds, color: Colors.white10);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Quick Action shortcuts
                  ValueListenableBuilder<UserRole>(
                    valueListenable: _appState.userRole,
                    builder: (context, role, _) {
                      final isBarber = role == UserRole.barber;
                      return Row(
                        children: [
                          Expanded(
                            child: AlcesCard(
                              padding: const EdgeInsets.all(12),
                              onTap: () {
                                final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                                if (mainScreenState != null) {
                                  mainScreenState.changeTab(1); // 1 is Booking
                                }
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGold.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                        isBarber ? Icons.add_circle_outline : Icons.calendar_today,
                                        color: AppTheme.primaryGold, 
                                        size: 20),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      isBarber ? 'Agendar' : 'Agendar',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AlcesCard(
                              padding: const EdgeInsets.all(12),
                              onTap: () {
                                final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                                if (mainScreenState != null) {
                                  mainScreenState.changeTab(2); // 2 is BarberAgenda for barber, Services for client
                                }
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGold.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                        isBarber ? Icons.event_note : Icons.cut,
                                        color: AppTheme.primaryGold, 
                                        size: 20),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      isBarber ? 'Agenda' : 'Serviços',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AlcesCard(
                              padding: const EdgeInsets.all(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ProductsScreen()),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGold.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.local_mall,
                                        color: AppTheme.primaryGold, size: 20),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Produtos',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ].animate(interval: 100.ms).fade().slideY(begin: 0.2),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Barbers Section
                  ValueListenableBuilder<UserRole>(
                    valueListenable: _appState.userRole,
                    builder: (context, role, _) {
                      if (role == UserRole.barber) {
                        return const SizedBox.shrink();
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nossa Equipe',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              const Text(
                                'Disponíveis hoje',
                                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 130, // Reduced height
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: storeBarbers.length,
                              itemBuilder: (context, index) {
                                final barber = storeBarbers[index];
                                return Container(
                                  width: 105, // Reduced width to fit 3 exactly
                                  margin: const EdgeInsets.only(right: 12), // Reduced margin
                                  child: AlcesCard(
                                    padding: EdgeInsets.zero,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Background Image
                                        if (barber.avatarUrl.isNotEmpty)
                                          Image(
                                            image: barber.avatarUrl.startsWith('http')
                                                ? NetworkImage(barber.avatarUrl)
                                                : AssetImage(barber.avatarUrl) as ImageProvider,
                                            fit: BoxFit.cover,
                                          )
                                        else
                                          Container(
                                            color: Colors.white10,
                                            child: Center(
                                              child: Text(barber.initials, style: const TextStyle(color: Colors.white, fontSize: 24)),
                                            ),
                                          ),
                                        
                                        // Gradient Overlay
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.8),
                                              ],
                                            ),
                                          ),
                                        ),
                                        
                                        // Texts
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          right: 8,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                barber.name.split(' ')[0],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                barber.isLeader ? 'Líder' : 'Barbeiro',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: barber.isLeader
                                                      ? AppTheme.primaryGold
                                                      : AppTheme.textMuted,
                                                  fontWeight: barber.isLeader
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).animate().fade(delay: (300 + (100 * index)).ms).slideX(begin: 0.2);
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),

                  // Footer / Info info
                  AlcesCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.access_time,
                                color: AppTheme.primaryGold, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Horário de Funcionamento',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Segunda a Sábado: ${currentStore.openTime} às ${currentStore.closeTime}',
                                    style: const TextStyle(
                                        fontSize: 13, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.phone,
                                color: AppTheme.primaryGold, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Contato e Whatsapp',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentStore.phone,
                                    style: const TextStyle(
                                        fontSize: 13, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 800.ms).slideY(begin: 0.2),
                ],
              ),
            );
          },
        ),
      ),
    ],
  ),
);
  }
}
