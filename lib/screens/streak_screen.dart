import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_state.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streak Saya')),
      body: Consumer<ReadingState>(
        builder: (context, state, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 100,
                  color: Colors.orange,
                ),
                Text(
                  'Streak saat ini: ${state.currentStreak}',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text(
                  'Lanjutkan! Setiap hari selesai tambah 1 streak.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali ke Rencana'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
