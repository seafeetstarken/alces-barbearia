import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/app_state.dart';
import '../models/store.dart';
import '../models/barber.dart';
import '../models/service_item.dart';
import '../models/appointment.dart';
import '../theme/app_theme.dart';
import '../widgets/alces_ui.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final AppState _appState = AppState();

  int _currentStep = 0; // 0: Service, 1: Barber, 2: Date & Time, 3: Summary

  List<ServiceItem> _selectedServices = [];
  Barber? _selectedBarber;
  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _timeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '13:30', '14:00', '14:30', '15:00', '15:30', '16:00',
    '16:30', '17:00', '17:30', '18:00', '18:30', '19:00'
  ];

  List<String> _unavailableSlots = [];
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    // Default to today for selected date
    _selectedDate = DateTime.now();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _resetBooking() {
    setState(() {
      _currentStep = 0;
      _selectedServices.clear();
      _selectedBarber = null;
      _selectedDate = DateTime.now();
      _selectedTime = null;
      _unavailableSlots = [];
    });
  }

  Future<void> _loadUnavailableSlots() async {
    if (_selectedBarber == null || _selectedDate == null) return;
    setState(() => _isLoadingSlots = true);
    final slots = await _appState.fetchBookedSlots(_selectedBarber!.id, _selectedDate!);
    if (mounted) {
      setState(() {
        _unavailableSlots = slots;
        _isLoadingSlots = false;
        if (_selectedTime != null && _unavailableSlots.contains(_selectedTime)) {
          _selectedTime = null;
        }
      });
    }
  }

  Future<void> _confirmBooking(Store store) async {
    if (_selectedServices.isEmpty || _selectedBarber == null || _selectedDate == null || _selectedTime == null) {
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
    );

    try {
      for (var service in _selectedServices) {
        final newAppt = Appointment(
          id: 'appt-${DateTime.now().millisecondsSinceEpoch}-${service.id.substring(0, 4)}',
          storeId: store.id,
          barberId: _selectedBarber!.id,
          serviceId: service.id,
          clientName: _appState.userName,
          date: _selectedDate!,
          time: _selectedTime!,
          status: 'confirmed',
        );
        await _appState.addAppointment(newAppt);
      }

      if (mounted) {
        Navigator.pop(context); // close loading
        _showSuccessDialog(store);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao agendar: $e')),
        );
      }
    }
  }

  void _showSuccessDialog(Store store) {
    final dateStr = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFF1B4332),
                child: Icon(Icons.check, color: Color(0xFF52B788), size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'Agendamento Confirmado!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Seu horário com ${_selectedBarber!.name.split(' ')[0]} foi marcado para o dia $dateStr às $_selectedTime na unidade ${store.name.replaceAll("Alce\'s Barbearia - ", "")}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              AlcesButton(
                text: 'Excelente',
                isPrimary: true,
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  _resetBooking();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= _currentStep;
        final isCurrent = index == _currentStep;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppTheme.primaryGold
                      : isActive
                          ? AppTheme.primaryGold.withOpacity(0.4)
                          : Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.black : Colors.white70,
                    ),
                  ),
                ),
              ),
              if (index < 3)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive
                        ? AppTheme.primaryGold.withOpacity(0.4)
                        : Colors.white.withOpacity(0.06),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildServiceSelection(List<ServiceItem> storeServices) {
    return ValueListenableBuilder<String?>(
      valueListenable: _appState.activePlan,
      builder: (context, activePlan, _) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: storeServices.length,
          itemBuilder: (context, index) {
            final service = storeServices[index];
            final isSelected = _selectedServices.any((s) => s.id == service.id);
            final discount = _appState.getDiscountForService(service);
            final finalPrice = service.price - discount;
            final isFreeByClub = discount == service.price && service.price > 0;

            return AlcesCard(
              padding: const EdgeInsets.all(12),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedServices.removeWhere((s) => s.id == service.id);
                  } else {
                    _selectedServices.add(service);
                  }
                });
              },
              border: Border.all(
                color: isSelected ? AppTheme.primaryGold : Colors.white.withOpacity(0.06),
                width: 1.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? AppTheme.primaryGold : Colors.white30,
                            size: 20,
                          ),
                          if (isFreeByClub)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF52B788).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFF52B788).withOpacity(0.3)),
                              ),
                              child: const Text('CLUBE', style: TextStyle(color: Color(0xFF52B788), fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text('${service.duration} min', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (isFreeByClub)
                        const Text('GRÁTIS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF52B788)))
                      else
                        Text('R\$ ${finalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBarberSelection(List<Barber> storeBarbers) {
    if (storeBarbers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Nenhum profissional disponível.', style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: storeBarbers.length,
      itemBuilder: (context, index) {
        final barber = storeBarbers[index];
        final isSelected = _selectedBarber?.id == barber.id;

        return AlcesCard(
          onTap: () {
            setState(() {
              _selectedBarber = barber;
              _selectedTime = null; // Clear time when barber changes
            });
            _loadUnavailableSlots();
            _nextStep();
          },
          border: Border.all(
            color: isSelected ? AppTheme.primaryGold : Colors.white.withOpacity(0.06),
            width: 1.5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(barber.avatarUrl),
                backgroundColor: Colors.white10,
              ),
              const SizedBox(height: 12),
              Text(
                barber.name.split(' ')[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isSelected ? AppTheme.primaryGold : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                barber.isLeader ? 'Profissional Líder' : 'Barbeiro',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateTimeSelection() {
    // Generate next 7 days starting from today
    final days = List.generate(7, (index) => DateTime.now().add(Duration(days: index)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione o Dia',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 12),
        // Horizontal calendar
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              final dayName = DateFormat('E', 'pt_BR').format(date).toUpperCase().replaceAll('.', '');
              final dayNum = DateFormat('dd').format(date);
              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                      _selectedTime = null; // Clear selected time on date change
                    });
                    _loadUnavailableSlots();
                  },
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryGold : AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryGold : Colors.white.withOpacity(0.06),
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
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Horários Disponíveis',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('Ocupado', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Grid of times slots
        if (_isLoadingSlots)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: AppTheme.primaryGold),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.0,
            ),
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final time = _timeSlots[index];
              // Our db stores time as '09:00:00', but timeSlots is '09:00'. We need to check both.
              final isUnavailable = _unavailableSlots.contains(time) || _unavailableSlots.contains('$time:00');
              final isSelected = _selectedTime == time;

            return GestureDetector(
              onTap: isUnavailable
                  ? null
                  : () => setState(() => _selectedTime = time),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGold
                      : isUnavailable
                          ? Colors.white.withOpacity(0.02)
                          : AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryGold
                        : isUnavailable
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.06),
                  ),
                ),
                child: Center(
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.black
                          : isUnavailable
                              ? Colors.white.withOpacity(0.12)
                              : Colors.white,
                      decoration: isUnavailable ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummarySection(Store store) {
    final dateStr = _selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : '';
    
    double totalOriginal = 0;
    double totalDiscount = 0;
    double finalPrice = 0;

    for (var service in _selectedServices) {
      totalOriginal += service.price;
      totalDiscount += _appState.getDiscountForService(service);
    }
    finalPrice = totalOriginal - totalDiscount;

    final serviceNames = _selectedServices.map((s) => s.name).join(' + ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirmação do Agendamento',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 16),
        AlcesCard(
          child: Column(
            children: [
              _buildSummaryRow(Icons.store, 'Unidade', store.name.replaceAll("Alce\'s Barbearia - ", "")),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow(Icons.cut, 'Serviços', serviceNames),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow(Icons.person, 'Barbeiro', _selectedBarber?.name ?? ''),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow(Icons.calendar_today, 'Data & Hora', '$dateStr às $_selectedTime'),
              
              const Divider(color: Colors.white12, height: 24),
              
              if (totalDiscount > 0) ...[
                _buildSummaryRow(
                  Icons.receipt,
                  'Valor Original',
                  'R\$ ${totalOriginal.toStringAsFixed(2).replaceAll('.', ',')}',
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  Icons.star,
                  'Benefício Clube Alce\'s',
                  '- R\$ ${totalDiscount.toStringAsFixed(2).replaceAll('.', ',')}',
                  valueColor: const Color(0xFF52B788),
                  isBoldValue: true,
                ),
                const Divider(color: Colors.white12, height: 24),
              ],

              _buildSummaryRow(
                Icons.wallet,
                'Valor a ser pago na loja',
                'R\$ ${finalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                valueColor: AppTheme.primaryGold,
                isBoldValue: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, {Color? valueColor, bool isBoldValue = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryGold, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
                  color: valueColor ?? Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
        centerTitle: true,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: ValueListenableBuilder<Store>(
        valueListenable: _appState.activeStore,
        builder: (context, activeStore, _) {
          // Filter barbers and services for active store
          final storeBarbers = _appState.barbers.value.where((b) => b.storeId == activeStore.id && b.isActive).toList();
          final storeServices = _appState.services.value.where((s) => s.storeId == activeStore.id || s.storeId == 'global').toList();

          return Column(
            children: [
              // Stepper indicator header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _buildStepIndicator(),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 0) ...[
                        const Text(
                          'Escolha o Serviço',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        _buildServiceSelection(storeServices),
                      ] else if (_currentStep == 1) ...[
                        const Text(
                          'Escolha o Profissional',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        _buildBarberSelection(storeBarbers),
                      ] else if (_currentStep == 2) ...[
                        _buildDateTimeSelection(),
                      ] else if (_currentStep == 3) ...[
                        _buildSummarySection(activeStore),
                      ],
                    ],
                  ),
                ),
              ),
              // Sticky actions bar at bottom
              if (_currentStep == 0 || _currentStep == 2 || _currentStep == 3)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark,
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        if (_currentStep == 0) ...[
                          Expanded(
                            child: AlcesButton(
                              text: 'Continuar',
                              isPrimary: true,
                              onPressed: _selectedServices.isNotEmpty ? _nextStep : null,
                            ),
                          ),
                        ] else if (_currentStep == 2) ...[
                          Expanded(
                            child: AlcesButton(
                              text: 'Revisar Agendamento',
                              isPrimary: true,
                              onPressed: _selectedTime != null ? _nextStep : null,
                            ),
                          ),
                        ] else if (_currentStep == 3) ...[
                          Expanded(
                            child: AlcesButton(
                              text: 'Confirmar e Agendar',
                              isPrimary: true,
                              onPressed: () => _confirmBooking(activeStore),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
