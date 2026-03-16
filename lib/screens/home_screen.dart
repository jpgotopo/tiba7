import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_state.dart';

import 'reading_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'lib/assets/Logo_Gereja_Sidang-Sidang_Jemaat_Allah.jpg',
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Tiba7'),
          ],
        ),
        actions: [
          Consumer<ReadingState>(
            builder: (context, state, child) => Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Chip(
                  avatar: const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                  label: Text(
                    '${state.currentStreak}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  side: BorderSide.none,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ReadingState>(
        builder: (context, state, child) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              // Month selector
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: state.selectedMonthIndex,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.indigo),
                      style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                      items: state.months
                          .asMap()
                          .entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          state.setSelectedMonth(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.selectedMonth.days.length,
                  itemBuilder: (context, index) {
                    final day = state.selectedMonth.days[index];
                    final monthIdx = state.selectedMonthIndex;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ExpansionTile(
                        title: Text('Hari ${day.number}'),
                        subtitle: Text(
                          day.allCompleted ? 'Selesai ✓' : 'Belum',
                        ),
                        children: [
                          ...day.passages.asMap().entries.map((entry) {
                            final passageIdx = entry.key;
                            final passage = entry.value;
                            final completed = state.isPassageCompleted(
                              monthIdx,
                              day.number,
                              passageIdx,
                            );
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: completed,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  activeColor: Theme.of(context).colorScheme.primary,
                                  onChanged: (val) {
                                    state.togglePassage(
                                      monthIdx,
                                      day.number,
                                      passageIdx,
                                    );
                                  },
                                ),
                              ),
                              title: Text(
                                passage.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  decoration: completed ? TextDecoration.lineThrough : null,
                                  color: completed ? Colors.grey : Colors.black87,
                                ),
                              ),
                              trailing: const Icon(Icons.menu_book, color: Colors.indigo, size: 20),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => Padding(
                                    padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).padding.top + 40,
                                    ),
                                    child: ReadingBottomSheet(reference: passage.text),
                                  ),
                                );
                              },
                            );
                          }),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FilledButton.icon(
                              icon: const Icon(Icons.done_all),
                              onPressed: () =>
                                  state.completeAllForDay(monthIdx, day.number),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              label: const Text('Tandai Semua Selesai'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
