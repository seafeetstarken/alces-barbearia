import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/user_role.dart';
import 'home_screen.dart';
import 'booking_screen.dart';
import 'services_screen.dart';
import 'club_screen.dart';
import 'profile_screen.dart';
import 'barber_agenda_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.loadInitialData();
  }

  List<Widget> get _screens {
    if (_appState.userRole.value == UserRole.barber) {
      return [
        const HomeScreen(),
        const BookingScreen(),
        const BarberAgendaScreen(),
        const ServicesScreen(),
        const ProfileScreen(),
      ];
    }
    return [
      const HomeScreen(),
      const BookingScreen(),
      const ServicesScreen(),
      const ClubScreen(),
      const ProfileScreen(),
    ];
  }

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _appState.isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            ),
          );
        }

        return ValueListenableBuilder<UserRole>(
          valueListenable: _appState.userRole,
          builder: (context, role, _) {
            final screensList = _screens;
            
            // Safe index adjustment in case of role switch
            if (_currentIndex >= screensList.length) {
              _currentIndex = 0;
            }

            final isBarber = role == UserRole.barber;

            return Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: screensList,
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: changeTab,
                items: isBarber
                    ? const [
                        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Agendar'),
                        BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Minha Agenda'),
                        BottomNavigationBarItem(icon: Icon(Icons.cut), label: 'Serviços'),
                        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
                      ]
                    : const [
                        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Agenda'),
                        BottomNavigationBarItem(icon: Icon(Icons.cut), label: 'Serviços'),
                        BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Clube'),
                        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
                      ],
              ),
            );
          },
        );
      },
    );
  }
}

