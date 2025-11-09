import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.lastTicket;
    final train = state.selectedTrain;

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: t == null
            ? const Center(child: Text('No ticket'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PNR: ${t.pnr}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (train != null) ...[
                    Text(train.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('${train.source} → ${train.destination}')
                  ],
                  const SizedBox(height: 8),
                  Text('Seat: ${t.seatNo}'),
                  Text('Status: ${t.status}'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/search', (_) => false),
                    child: const Text('Back to Search'),
                  )
                ],
              ),
      ),
    );
  }
}
