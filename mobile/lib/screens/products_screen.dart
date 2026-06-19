import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/alces_ui.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Produtos'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Store>(
        valueListenable: _appState.activeStore,
        builder: (context, activeStore, _) {
          // Get products for this store
          final storeProducts = _appState.products.value.toList();

          // Group products by category
          final Map<String, List<ProductItem>> categorized = {};
          for (var item in storeProducts) {
            if (!categorized.containsKey(item.category)) {
              categorized[item.category] = [];
            }
            categorized[item.category]!.add(item);
          }

          if (storeProducts.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum produto cadastrado para esta unidade.',
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75, // Taller cards for images
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final product = items[index];
                      return AlcesCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Product Image Placeholder
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: AppTheme.textMuted,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            // Product Details
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
