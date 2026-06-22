import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/plan.dart';
import '../core/theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
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
      setState(() {
        _users = users;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar usuários: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text('Atribuir Plano Manualmente', style: TextStyle(color: AppColors.textPrimary)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente: ${user['full_name'] ?? 'Sem nome'}', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SubscriptionPlan>(
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      labelText: 'Selecione o Plano',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                    ),
                    items: appState.plans.value.map((plan) {
                      return DropdownMenuItem<SubscriptionPlan>(
                        value: plan,
                        child: Text(plan.name, style: TextStyle(color: AppColors.textPrimary)),
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
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (selectedPlan == null) return;
                    
                    try {
                      // Mostra um loading
                      Navigator.pop(context); // Fechar dialog atual
                      
                      showDialog(
                        context: context, 
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator())
                      );

                      await appState.assignPlanToUser(user['id'], selectedPlan!.id);
                      
                      Navigator.pop(context); // Fechar loading
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Plano ${selectedPlan!.name} atribuído com sucesso!')),
                      );
                    } catch (e) {
                      Navigator.pop(context); // Fechar loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao atribuir plano: $e')),
                      );
                    }
                  },
                  child: const Text('Confirmar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
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
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                title: Text(user['full_name'] ?? 'Usuário sem nome', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text(user['phone'] ?? 'Sem telefone', style: TextStyle(color: AppColors.textSecondary)),
                trailing: IconButton(
                  icon: Icon(Icons.card_membership, color: AppColors.primary),
                  onPressed: () => _showAssignPlanDialog(user),
                  tooltip: 'Atribuir Plano',
                ),
              );
            },
          ),
    );
  }
}
