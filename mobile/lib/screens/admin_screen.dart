import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/plan.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final appState = AppState();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await appState.fetchAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar usuários: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAssignPlanDialog(Map<String, dynamic> user) {
    SubscriptionPlan? selectedPlan;
    
    if (appState.plans.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum plano disponível cadastrado no sistema.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: const Text('Atribuir Plano Manualmente', style: TextStyle(color: AppTheme.textLight)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente: ${user['full_name'] ?? 'Sem nome'}', style: const TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SubscriptionPlan>(
                    dropdownColor: AppTheme.cardDark,
                    decoration: const InputDecoration(
                      labelText: 'Selecione o Plano',
                      labelStyle: TextStyle(color: AppTheme.textMuted),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    ),
                    items: appState.plans.value.map((plan) {
                      return DropdownMenuItem<SubscriptionPlan>(
                        value: plan,
                        child: Text(plan.name, style: const TextStyle(color: AppTheme.textLight)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedPlan = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
                  onPressed: isSaving ? null : () async {
                    if (selectedPlan == null) return;
                    
                    setDialogState(() {
                      isSaving = true;
                    });
                    
                    try {
                      await appState.assignPlanToUser(user['id'], selectedPlan!.id);
                      
                      if (mounted) {
                        Navigator.pop(context); // Fechar dialog atual
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Plano ${selectedPlan!.name} atribuído com sucesso!')),
                        );
                      }
                    } catch (e) {
                      setDialogState(() {
                        isSaving = false;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao atribuir plano: $e')),
                        );
                      }
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Confirmar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        backgroundColor: AppTheme.cardDark,
        foregroundColor: AppTheme.primaryGold,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryGold.withOpacity(0.2),
                  child: const Icon(Icons.person, color: AppTheme.primaryGold),
                ),
                title: Text(user['full_name'] ?? 'Usuário sem nome', style: const TextStyle(color: AppTheme.textLight)),
                subtitle: Text(user['phone'] ?? 'Sem telefone', style: const TextStyle(color: AppTheme.textMuted)),
                trailing: IconButton(
                  icon: const Icon(Icons.card_membership, color: AppTheme.primaryGold),
                  onPressed: () => _showAssignPlanDialog(user),
                  tooltip: 'Atribuir Plano',
                ),
              );
            },
          ),
    );
  }
}
