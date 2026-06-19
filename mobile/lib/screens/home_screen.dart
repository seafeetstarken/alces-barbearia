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

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Bar Header (Brand + Pill Selector)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cut, color: AppTheme.primaryGold, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                "ALCE'S BARBEARIA",
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  color: AppTheme.primaryGold,
                                ),
                              ),
                            ],
                          ),
                          // Location Pill Button
                          InkWell(
                            onTap: () => _showStoreSelector(context),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.cardDark.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withOpacity(0.06)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: AppTheme.primaryGold, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    currentStore.name.replaceAll("Alce's Barbearia - ", ""),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.expand_more, color: AppTheme.textMuted, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ].animate().fade(duration: 500.ms).slideY(begin: -0.2),
                      ),
                      const SizedBox(height: 24),

                      // Welcome Card & Gamification (Glassmorphism)
                      _buildGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: AppTheme.primaryGold.withOpacity(0.1),
                                backgroundImage: const NetworkImage(
                                  'https://api.dicebear.com/7.x/avataaars/png?seed=AlcesUser&backgroundColor=18181B',
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.cardDark,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                                        ),
                                        child: const Icon(Icons.military_tech, color: AppTheme.primaryGold, size: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Olá, ${_appState.userName}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
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
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primaryGold.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
                                                    ),
                                                    child: const Text(
                                                      'Alces Games',
                                                      style: TextStyle(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Lvl $level • $xp XP • $coins Coins',
                                                    style: const TextStyle(
                                                      color: AppTheme.primaryGold,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
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
                            child: AlcesCard(
                              padding: const EdgeInsets.all(24),
                              border: Border.all(
                                color: hasActivePlan ? AppTheme.statusSuccess.withOpacity(0.3) : AppTheme.primaryGold.withOpacity(0.3),
                                width: 1,
                              ),
                              child: Stack(
                                children: [
                                  // Inner glow
                                  Positioned(
                                    right: -50,
                                    top: -50,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.primaryGold.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(hasActivePlan ? Icons.verified : Icons.star, color: AppTheme.primaryGold, size: 14),
                                            const SizedBox(width: 6),
                                            Text(
                                              hasActivePlan ? 'MEMBRO EXCLUSIVO' : 'CLUBE ALCE\'S',
                                              style: const TextStyle(
                                                color: AppTheme.primaryGold,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        hasActivePlan ? planName : 'Corte o cabelo ilimitado no mês.',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(color: AppTheme.primaryGold.withOpacity(0.4), blurRadius: 10),
                                          ],
                                        ),
                                      ),
                                      if (!hasActivePlan) ...[
                                        const SizedBox(height: 8),
                                        const Text(
                                          'A partir de R\$ 89,90/mês.',
                                          style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                                        ),
                                      ],
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
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 8,
                                          shadowColor: AppTheme.primaryGold.withOpacity(0.5),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              hasActivePlan ? 'GERENCIAR ASSINATURA' : 'ASSINAR AGORA',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward, size: 16),
                                          ],
                                        ),
                                      ),
                                    ],
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
