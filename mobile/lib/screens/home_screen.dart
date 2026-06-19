import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_state.dart';
import '../models/store.dart';
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

  // Helper widget for Glassmorphism Cards
  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding, VoidCallback? onTap}) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Global Ambient Glow Background
          Positioned(
            top: -100,
            left: -100,
            right: -100,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGold.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withOpacity(0.08),
                    blurRadius: 120,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: ValueListenableBuilder<Store>(
              valueListenable: _appState.activeStore,
              builder: (context, currentStore, _) {
                final storeBarbers = _appState.barbers.value
                    .where((b) => b.storeId == currentStore.id && b.isActive)
                    .toList();

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

  // Helper widget for Glassmorphism Cards
  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding, VoidCallback? onTap}) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Global Ambient Glow Background
          Positioned(
            top: -100,
            left: -100,
            right: -100,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGold.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withOpacity(0.08),
                    blurRadius: 120,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: ValueListenableBuilder<Store>(
              valueListenable: _appState.activeStore,
              builder: (context, currentStore, _) {
                final storeBarbers = _appState.barbers.value
                    .where((b) => b.storeId == currentStore.id && b.isActive)
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Bar Header (Brand + Location Button)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.cardDark,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: const Center(
                                  child: Text(
                                    'A',
                                    style: TextStyle(
                                      color: AppTheme.primaryGold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "ALCE'S BARBEARIA",
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1.0,
                                  color: AppTheme.primaryGold,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => _showStoreSelector(context),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.cardDark.withOpacity(0.7),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.06)),
                              ),
                              child: const Icon(Icons.location_on, color: AppTheme.primaryGold, size: 20),
                            ),
                          ),
                        ].animate().fade(duration: 500.ms).slideY(begin: -0.2),
                      ),
                      const SizedBox(height: 24),

                      // Welcome Card & Gamification (Glassmorphism)
                      _buildGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bem-vindo de volta,',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    Text(
                                      _appState.userName,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                ValueListenableBuilder<int>(
                                  valueListenable: _appState.userLevel,
                                  builder: (context, level, _) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.statusSuccess.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppTheme.statusSuccess.withOpacity(0.5)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.military_tech, color: AppTheme.statusSuccess, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Level $level',
                                            style: const TextStyle(
                                              color: AppTheme.statusSuccess,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ValueListenableBuilder<int>(
                              valueListenable: _appState.userXp,
                              builder: (context, xp, _) {
                                return ValueListenableBuilder<int>(
                                  valueListenable: _appState.userCoins,
                                  builder: (context, coins, _) {
                                    return Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Experiência', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                                            Text('$xp XP', style: const TextStyle(color: AppTheme.primaryGold, fontSize: 20, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(width: 24),
                                        Container(height: 32, width: 1, color: Colors.white.withOpacity(0.1)),
                                        const SizedBox(width: 24),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Saldo', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                                            Text('$coins Coins', style: const TextStyle(color: AppTheme.primaryGold, fontSize: 20, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                );
                              }
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 600.ms).scale(begin: const Offset(0.95, 0.95)),
                      const SizedBox(height: 24),

                      // Club Banner Promo (Glow Effect)
                      ValueListenableBuilder<String?>(
                        valueListenable: _appState.activePlan,
                        builder: (context, planName, _) {
                          final hasActivePlan = planName != null;
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGold.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.cardDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primaryGold.withOpacity(0.3),
                                  width: 1,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppTheme.cardDark.withOpacity(0.8),
                                    AppTheme.cardDark,
                                  ]
                                )
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.diamond, color: AppTheme.primaryGold, size: 32),
                                  const SizedBox(height: 12),
                                  Text(
                                    hasActivePlan ? 'Membro Exclusivo' : 'Clube Alce\'s',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    hasActivePlan ? planName : 'Experiência premium ilimitada. Junte-se à elite.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                                      if (mainScreenState != null) {
                                        mainScreenState.changeTab(3); // Club tab
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGold,
                                      foregroundColor: AppTheme.backgroundDark,
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      elevation: 8,
                                      shadowColor: AppTheme.primaryGold.withOpacity(0.5),
                                    ),
                                    child: Text(
                                      hasActivePlan ? 'GERENCIAR' : 'Assinar Agora',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 3.seconds, color: Colors.white10);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Quick Action Bento Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildGlassCard(
                              onTap: () {
                                final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                                if (mainScreenState != null) mainScreenState.changeTab(1); // Agenda
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardDark,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: const Icon(Icons.calendar_month, color: AppTheme.primaryGold, size: 24),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Agendar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGlassCard(
                              onTap: () {
                                final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                                if (mainScreenState != null) mainScreenState.changeTab(2); // Servicos
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardDark,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: const Icon(Icons.content_cut, color: AppTheme.primaryGold, size: 24),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Serviços', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGlassCard(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductsScreen()));
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardDark,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: const Icon(Icons.inventory_2, color: AppTheme.primaryGold, size: 24),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Produtos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ].animate(interval: 100.ms).fade().slideY(begin: 0.2),
                      ),
                      const SizedBox(height: 32),

                      // Barbers Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Profissionais Disponíveis',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Ver todos',
                            style: TextStyle(fontSize: 12, color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: storeBarbers.length,
                          itemBuilder: (context, index) {
                            final barber = storeBarbers[index];
                            return Container(
                              width: 130,
                              margin: const EdgeInsets.only(right: 16),
                              child: _buildGlassCard(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 36,
                                          backgroundImage: NetworkImage(barber.avatarUrl),
                                          backgroundColor: Colors.white10,
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 4,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: AppTheme.statusSuccess,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: AppTheme.backgroundDark, width: 3),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      barber.name.split(' ')[0],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      barber.isLeader ? 'Líder' : 'Barbeiro',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fade(delay: (300 + (100 * index)).ms).slideX(begin: 0.2);
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Info Footer
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "© 2024 Alce's Barbearia",
                              style: TextStyle(color: AppTheme.textMuted.withOpacity(0.5), fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Versão 1.0.0",
                              style: TextStyle(color: AppTheme.textMuted.withOpacity(0.3), fontSize: 10),
                            ),
                          ],
                        ),
                      ),
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
