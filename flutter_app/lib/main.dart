import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/search_screen.dart';
import 'screens/results_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/ticket_screen.dart';
import 'services/app_state.dart';

void main() {
  runApp(const RailSmartApp());
}

class RailSmartApp extends StatelessWidget {
  const RailSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RailSmart',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/search': (context) => const SearchScreen(),
          '/results': (context) => const ResultsScreen(),
          '/booking': (context) => const BookingScreen(),
          '/ticket': (context) => const TicketScreen(),
        },
      ),
    );
  }
}
