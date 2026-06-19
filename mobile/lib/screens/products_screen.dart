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
  bool _isReserving = false;

  void _handleReservation() async {
    setState(() => _isReserving = true);
    try {
      await _appState.reserveProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produtos reservados com sucesso! Retire no balcão.'),
            backgroundColor: Color(0xFF52B788),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reservar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReserving = false);
      }
    }
  }

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
          final storeProducts = _appState.products.value.toList();

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

          return ValueListenableBuilder<Map<ProductItem, int>>(
            valueListenable: _appState.cart,
            builder: (context, cart, _) {
              return Stack(
                children: [
                  ListView.builder(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: cart.isNotEmpty ? 100.0 : 16.0),
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
                              style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16.0,
                              crossAxisSpacing: 16.0,
                              childAspectRatio: 0.65,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final product = items[index];
                              final qty = cart[product] ?? 0;

                              return AlcesCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        ),
                                        child: const Center(child: Icon(Icons.image_not_supported, color: AppTheme.textMuted, size: 40.0)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.white),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                                              style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                                            ),
                                            const SizedBox(height: 4.0),
                                            if (qty == 0)
                                              SizedBox(
                                                width: double.infinity,
                                                height: 32,
                                                child: ElevatedButton(
                                                  onPressed: () => _appState.addToCart(product),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppTheme.primaryGold.withOpacity(0.15),
                                                    foregroundColor: AppTheme.primaryGold,
                                                    elevation: 0.0,
                                                    padding: EdgeInsets.zero,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                                  ),
                                                  child: const Text('Adicionar', style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
                                                ),
                                              )
                                            else
                                              Container(
                                                height: 32.0,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.cardDark,
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.remove, size: 16.0, color: AppTheme.primaryGold),
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                      onPressed: () => _appState.removeFromCart(product),
                                                    ),
                                                    Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                                    IconButton(
                                                      icon: const Icon(Icons.add, size: 16.0, color: AppTheme.primaryGold),
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                      onPressed: () => _appState.addToCart(product),
                                                    ),
                                                  ],
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
                        ],
                      );
                    },
                  ),
                  if (cart.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10.0, offset: const Offset(0.0, -5.0))],
                          border: Border(top: Border.all(color: Colors.white.withOpacity(0.1))),
                        ),
                        child: SafeArea(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Total da Reserva', style: TextStyle(color: AppTheme.textMuted, fontSize: 12.0)),
                                  Text(
                                    'R\$ ${_appState.cartTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: const TextStyle(color: AppTheme.primaryGold, fontSize: 20.0, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: _isReserving ? null : () => _handleReservation(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGold,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                ),
                                child: _isReserving
                                    ? const SizedBox(width: 20.0, height: 20.0, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.0))
                                    : const Text('Reservar', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
