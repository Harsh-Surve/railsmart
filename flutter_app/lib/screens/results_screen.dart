import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/train.dart';
import '../services/app_state.dart';
import '../widgets/train_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final List<Train> trains = state.currentResults;

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: trains.isEmpty
          ? const Center(child: Text('No trains found'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, i) {
                final t = trains[i];
                return TrainCard(
                  train: t,
                  onBook: () {
                    state.selectedTrain = t;
                    Navigator.pushNamed(context, '/booking');
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: trains.length,
            ),
    );
  }
}
