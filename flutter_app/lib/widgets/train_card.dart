import 'package:flutter/material.dart';
import '../models/train.dart';

class TrainCard extends StatelessWidget {
  final Train train;
  final VoidCallback? onBook;
  const TrainCard({super.key, required this.train, this.onBook});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(train.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${train.source} → ${train.destination}'),
                  const SizedBox(height: 4),
                  Text('${train.departure} → ${train.arrival}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onBook,
              child: const Text('Book'),
            )
          ],
        ),
      ),
    );
  }
}
