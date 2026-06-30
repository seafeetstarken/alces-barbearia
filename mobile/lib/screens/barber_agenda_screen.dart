import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/app_state.dart';
import '../models/barber_appointment_view.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';
import '../widgets/alces_ui.dart';

class BarberAgendaScreen extends StatefulWidget {
  const BarberAgendaScreen({super.key});

  @override
  State<BarberAgendaScreen> createState() => _BarberAgendaScreenState();
}

class _BarberAgendaScreenState extends State<BarberAgendaScreen> {
  final AppState _appState = AppState();
  DateTime _selectedDate = DateTime.now();
  List<BarberAppointmentView> _appointments = [];
  bool _isLoading = false;

  final List<String> _timeSlots = [
    '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00',
    '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00',
    '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30'
  ];

  late List<DateTime> _calendarDays;
  final ScrollController _calendarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Gera 14 dias a partir de hoje (remove dias anteriores)
    _calendarDays = List.generate(14, (index) {
      return DateTime.now().add(Duration(days: index));
    });
    _loadAgenda();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    if (!_calendarScrollController.hasClients) return;
    
    final index = _calendarDays.indexWhere((date) =>
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day);
        
    if (index != -1) {
      const itemWidth = 70.0; // 58 container width + 12 margin (6 on each side)
      final screenWidth = MediaQuery.of(context).size.width;
      final targetScroll = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
      
      _calendarScrollController.animateTo(
        targetScroll.clamp(0.0, _calendarScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadAgenda() async {
    final barber = _appState.linkedBarber.value;
    if (barber == null) return;

    setState(() => _isLoading = true);
    try {
      final agenda = await _appState.barberRepo.fetchDayAgenda(barber.id, _selectedDate);
      setState(() {
        _appointments = agenda;
      });
    } catch (e) {
      debugPrint('Erro ao carregar agenda: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double get _estimatedRevenue {
    double total = 0;
    for (var appt in _appointments) {
      if (appt.status.toLowerCase() != 'cancelado' && appt.status.toLowerCase() != 'cancelled') {
        total += appt.servicePrice;
      }
    }
    return total;
  }

  int get _activeCount {
    return _appointments.where((appt) => 
      appt.status.toLowerCase() != 'cancelado' && appt.status.toLowerCase() != 'cancelled'
    ).length;
  }

  bool _isSlotCoveredByPreviousAppt(String slotTime) {
    final slotParts = slotTime.split(':');
    final slotMin = int.parse(slotParts[0]) * 60 + int.parse(slotParts[1]);

    for (var appt in _appointments) {
      if (appt.status.toLowerCase() == 'cancelado' || appt.status.toLowerCase() == 'cancelled') {
        continue;
      }
      final apptParts = appt.time.split(':');
      final apptMin = int.parse(apptParts[0]) * 60 + int.parse(apptParts[1]);
      final apptEnd = apptMin + appt.durationMinutes;

      // Se começa exatamente agora, nós mostramos o card (não está coberto)
      if (appt.time == slotTime) {
        return false;
      }

      // Se o slot cai no meio do atendimento
      if (slotMin >= apptMin && slotMin < apptEnd) {
        return true;
      }
    }
    return false;
  }

  Future<void> _changeAppointmentStatus(String appointmentId, String newStatus, String actionName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text('Confirmar Ação', style: TextStyle(color: Colors.white)),
        content: Text('Deseja marcar este agendamento como "$actionName"?', style: TextStyle(color: AppTheme.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _appState.barberRepo.updateAppointmentStatus(appointmentId, newStatus);
        _loadAgenda();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Agendamento $actionName com sucesso!'),
              backgroundColor: newStatus == 'Concluído' || newStatus == 'completed' 
                  ? AppTheme.statusSuccess 
                  : AppTheme.statusError,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar agendamento: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final barber = _appState.linkedBarber.value;
    if (barber == null) {
      return const Scaffold(
        body: Center(
          child: Text('Nenhum barbeiro vinculado a esta conta.', style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }

    final todayStr = DateFormat('dd/MM').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Minha Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryGold),
            onPressed: _loadAgenda,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAgenda,
        color: AppTheme.primaryGold,
        backgroundColor: AppTheme.cardDark,
        child: Column(
          children: [
            // Horizontal calendar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.black12,
              height: 96,
              child: ListView.builder(
                controller: _calendarScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _calendarDays.length,
                itemBuilder: (context, index) {
                  final date = _calendarDays[index];
                  final dayName = DateFormat('E', 'pt_BR').format(date).toUpperCase().replaceAll('.', '');
                  final dayNum = DateFormat('dd').format(date);
                  final isSelected = _selectedDate.year == date.year &&
                      _selectedDate.month == date.month &&
                      _selectedDate.day == date.day;
                  final isToday = DateTime.now().year == date.year &&
                      DateTime.now().month == date.month &&
                      DateTime.now().day == date.day;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                        _loadAgenda();
                        _scrollToSelectedDate();
                      },
                      child: Container(
                        width: 58,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppTheme.primaryGold 
                              : isToday 
                                  ? AppTheme.primaryGold.withOpacity(0.12)
                                  : AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? AppTheme.primaryGold 
                                : isToday
                                    ? AppTheme.primaryGold.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.06),
                            width: isToday ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dayNum,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Summary bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: AlcesCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Agendamentos', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              const SizedBox(height: 4),
                              Text('$_activeCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                          Container(width: 1, height: 30, color: Colors.white12),
                          Column(
                            children: [
                              const Text('Estimado', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              const SizedBox(height: 4),
                              Text('R\$ ${_estimatedRevenue.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Timeline slots
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _timeSlots.length,
                      itemBuilder: (context, index) {
                        final slotTime = _timeSlots[index];
                        
                        // Verifica se este slot está "escondido" (coberto) pelo agendamento anterior
                        if (_isSlotCoveredByPreviousAppt(slotTime)) {
                          return const SizedBox.shrink();
                        }

                        // Busca se existe algum agendamento que inicia neste horário
                        final appt = _appointments.firstWhere(
                          (a) => a.time == slotTime,
                          orElse: () => BarberAppointmentView(
                            id: '', clientName: '', serviceName: '', servicePrice: 0,
                            date: DateTime.now(), time: '', durationMinutes: 0, status: ''
                          ),
                        );

                        final isOccupied = appt.id.isNotEmpty;

                        if (isOccupied) {
                          final statusLower = appt.status.toLowerCase();
                          final isCanceled = statusLower == 'cancelado' || statusLower == 'cancelled';
                          final isCompleted = statusLower == 'concluído' || statusLower == 'completed';

                          Color statusColor = AppTheme.primaryGold;
                          if (isCompleted) statusColor = AppTheme.statusSuccess;
                          if (isCanceled) statusColor = AppTheme.statusError;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hora lateral
                                SizedBox(
                                  width: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      slotTime,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                                // Card do agendamento
                                Expanded(
                                  child: Opacity(
                                    opacity: (isCanceled || isCompleted) ? 0.6 : 1.0,
                                    child: AlcesCard(
                                      padding: const EdgeInsets.all(14),
                                      border: Border.all(color: statusColor.withOpacity(0.4), width: 1.2),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(

                                                child: Text(

                                                  appt.clientName,

                                                  style: TextStyle(

                                                    fontSize: 16,

                                                    fontWeight: FontWeight.bold,

                                                    color: Colors.white,

                                                    decoration: isCanceled ? TextDecoration.lineThrough : null,

                                                  ),

                                                  overflow: TextOverflow.ellipsis,

                                                ),

                                              ),

                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  appt.status,
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.cut, size: 14, color: AppTheme.textMuted),
                                              const SizedBox(width: 6),
                                              Expanded(

                                                child: Text(

                                                  appt.serviceName,

                                                  style: const TextStyle(fontSize: 13, color: AppTheme.textLight),

                                                  overflow: TextOverflow.ellipsis,

                                                ),

                                              ),

                                              const SizedBox(width: 8),
                                              Text(
                                                'R\$ ${appt.servicePrice.toStringAsFixed(2).replaceAll('.', ',')}',
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Duração: ${appt.durationMinutes} min',
                                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                              ),
                                            ],
                                          ),
                                          // Ações de status (Apenas se não cancelado/concluído)
                                          if (!isCanceled && !isCompleted) ...[
                                            const Divider(color: Colors.white12, height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () => _changeAppointmentStatus(appt.id, 'Cancelado', 'Cancelado'),
                                                  icon: const Icon(Icons.close, size: 14, color: AppTheme.statusError),
                                                  label: const Text('Cancelar', style: TextStyle(color: AppTheme.statusError, fontSize: 12)),
                                                ),
                                                const SizedBox(width: 12),
                                                ElevatedButton.icon(
                                                  onPressed: () => _changeAppointmentStatus(appt.id, 'Concluído', 'Concluído'),
                                                  icon: const Icon(Icons.check, size: 14, color: Colors.black),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppTheme.statusSuccess,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  label: const Text('Concluir', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                                                ),
                                              ],
                                            )
                                          ]
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Slot Livre (Disponível)
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                // Hora lateral
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    slotTime,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white30,
                                    ),
                                  ),
                                ),
                                // Linha de disponível
                                Expanded(
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white.withOpacity(0.02), width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white.withOpacity(0.005),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add, size: 14, color: Colors.white24),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Horário Livre',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withOpacity(0.24),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
