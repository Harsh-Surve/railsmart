import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _seat = TextEditingController();
  String _class = 'AC';
  final _passenger = TextEditingController();

  @override
  void dispose() {
    _seat.dispose();
    _passenger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final train = state.selectedTrain;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (train != null)
              Text('${train.name}  •  ${train.source} → ${train.destination}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _class,
              items: const [
                DropdownMenuItem(value: 'AC', child: Text('AC')),
                DropdownMenuItem(value: 'Sleeper', child: Text('Sleeper')),
                DropdownMenuItem(value: 'Second', child: Text('Second')),
              ],
              onChanged: (v) => setState(() => _class = v ?? 'AC'),
              decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _seat,
              decoration: const InputDecoration(labelText: 'Seat No (e.g., A1)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passenger,
              decoration: const InputDecoration(labelText: 'Passenger Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: state.loading
                  ? null
                  : () async {
                      if (train == null) return;
                      if (_seat.text.trim().isEmpty || _passenger.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter seat and passenger name')),
                        );
                        return;
                      }
                      final ok = await state.book(
                        train: train,
                        seatNo: _seat.text.trim(),
                        travelClass: _class,
                        passengerName: _passenger.text.trim(),
                      );
                      if (!mounted) return;
                      if (ok) {
                        Navigator.pushReplacementNamed(context, '/ticket');
                      } else if (state.lastError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.lastError!)),
                        );
                      }
                    },
              child: state.loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Confirm Booking'),
            )
          ],
        ),
      ),
    );
  }
}
