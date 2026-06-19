import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/store.dart';
import '../models/service_item.dart';
import '../theme/app_theme.dart';
import '../widgets/alces_ui.dart';
import 'main_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossos Serviços'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Store>(
        valueListenable: _appState.activeStore,
        builder: (context, activeStore, _) {
          // Get services for this store or global
          final storeServices = _appState.services.value
              .where((s) => s.storeId == activeStore.id || s.storeId == 'global')
              .toList();

          // Group services by category
          final Map<String, List<ServiceItem>> categorized = {};
          for (var item in storeServices) {
            if (!categorized.containsKey(item.category)) {
              categorized[item.category] = [];
            }
            categorized[item.category]!.add(item);
          }

          if (storeServices.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum serviço cadastrado para esta unidade.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categorized.length,
            itemBuilder: (context, catIndex) {
              final category = categorized.keys.elementAt(catIndex);
              final items = categorized[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  ...items.map((service) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AlcesCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  'R\$ ${service.price.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              service.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${service.duration} min',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 36,
                                  width: 100,
                                  child: AlcesButton(
                                    text: 'Agendar',
                                    isPrimary: true,
                                    onPressed: () {
                                      // Switch tab to Booking (Index 1)
                                      final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                                      if (mainScreenState != null) {
                                        mainScreenState.changeTab(1); // 1 is Agenda
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
