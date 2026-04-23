import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_state.dart';
import 'reading_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _listScrollController;
  late ScrollController _monthScrollController;

  // Passage type metadata: label, color, icon
  static const List<Map<String, dynamic>> _passageTypes = [
    {
      'key': 'PL',
      'label': 'PL',
      'fullLabel': 'Perjanjian Lama',
      'color': Color(0xFF1E3A8A),
      'icon': Icons.history_edu,
    },
    {
      'key': 'PB',
      'label': 'PB',
      'fullLabel': 'Perjanjian Baru',
      'color': Color(0xFFEA580C),
      'icon': Icons.auto_stories,
    },
    {
      'key': 'Mzm',
      'label': 'Mzm',
      'fullLabel': 'Mazmur',
      'color': Color(0xFF7C3AED),
      'icon': Icons.music_note,
    },
    {
      'key': 'Ams',
      'label': 'Ams',
      'fullLabel': 'Amsal',
      'color': Color(0xFF059669),
      'icon': Icons.lightbulb_outline,
    },
  ];

  @override
  void initState() {
    super.initState();
    _listScrollController = ScrollController();
    _monthScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToTodayIfCurrentMonth(),
    );
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _monthScrollController.dispose();
    super.dispose();
  }

  void _scrollToTodayIfCurrentMonth() {
    final state = context.read<ReadingState>();
    final now = DateTime.now();
    final isCurrentMonth = state.selectedMonthIndex == now.month - 1;
    if (!isCurrentMonth) return;
    final todayIndex = now.day - 1;
    // Each card is approximately 72px tall
    final offset = (todayIndex * 72.0).clamp(0.0, double.infinity);
    if (_listScrollController.hasClients) {
      _listScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollMonthChipIntoView(int index) {
    // Each chip is approximately 88px wide
    final offset = (index * 88.0) - 40.0;
    if (_monthScrollController.hasClients) {
      _monthScrollController.animateTo(
        offset.clamp(0.0, double.infinity),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ReadingState>(
        builder: (context, state, child) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();
          final isCurrentMonth = state.selectedMonthIndex == now.month - 1;
          final todayDay = now.day;
          final monthPercent = state.currentMonthCompletionPercentage;

          return CustomScrollView(
            controller: _listScrollController,
            slivers: [
              // ── Gradient Header ─────────────────────────────────────
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: const Color(0xFF1E3A8A),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFFEA580C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'lib/assets/Logo_Gereja_Sidang-Sidang_Jemaat_Allah.jpg',
                                height: 44,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tiba7',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  'Rencana Bacaan Alkitab',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Streak chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${state.currentStreak}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  collapseMode: CollapseMode.parallax,
                  title: const Text(
                    'Tiba7',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 16,
                    bottom: 14,
                  ),
                ),
              ),

              // ── Month selector ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      controller: _monthScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.months.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == state.selectedMonthIndex;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              state.months[index].name.substring(0, 3),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1E3A8A),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              state.setSelectedMonth(index);
                              _scrollMonthChipIntoView(index);
                              _listScrollController.jumpTo(0);
                            },
                            selectedColor: const Color(0xFF1E3A8A),
                            backgroundColor: const Color(0xFFF0F4FF),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFFCDD5E0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Monthly progress summary ─────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${state.selectedMonth.name} — ${state.completedDaysInCurrentMonth} dari ${state.selectedMonth.days.length} hari selesai',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${monthPercent.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: monthPercent / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            monthPercent >= 100
                                ? const Color(0xFF059669)
                                : const Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Legend ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Wrap(
                    spacing: 12,
                    children: _passageTypes.map((type) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: type['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            type['fullLabel'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ── Day list ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final day = state.selectedMonth.days[index];
                    final isToday = isCurrentMonth && day.number == todayDay;
                    return _DayCard(
                      day: day,
                      monthIdx: state.selectedMonthIndex,
                      isToday: isToday,
                      state: state,
                      passageTypes: _passageTypes,
                    );
                  }, childCount: state.selectedMonth.days.length),
                ),
              ),
            ],
          );
        },
      ),
      // ── FAB: Jump to today ────────────────────────────────────────
      floatingActionButton: Consumer<ReadingState>(
        builder: (context, state, _) {
          final now = DateTime.now();
          return FloatingActionButton.extended(
            onPressed: () {
              if (state.selectedMonthIndex != now.month - 1) {
                state.setSelectedMonth(now.month - 1);
                _scrollMonthChipIntoView(now.month - 1);
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToTodayIfCurrentMonth();
              });
            },
            backgroundColor: const Color(0xFFEA580C),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.today),
            label: const Text(
              'Hari Ini',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 4,
          );
        },
      ),
    );
  }
}

// ── Day Card Widget ───────────────────────────────────────────────────────────
class _DayCard extends StatelessWidget {
  final dynamic day;
  final int monthIdx;
  final bool isToday;
  final ReadingState state;
  final List<Map<String, dynamic>> passageTypes;

  const _DayCard({
    required this.day,
    required this.monthIdx,
    required this.isToday,
    required this.state,
    required this.passageTypes,
  });

  @override
  Widget build(Context context) {
    final completedCount = List.generate(
      day.passages.length,
      (i) => i,
    ).where((i) => state.isPassageCompleted(monthIdx, day.number, i)).length;
    final totalPassages = day.passages.length;
    final allDone = completedCount == totalPassages && totalPassages > 0;
    final progress = totalPassages > 0 ? completedCount / totalPassages : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(color: const Color(0xFFEA580C), width: 2)
            : Border.all(color: Colors.grey.withOpacity(0.15)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: isToday
                ? const Color(0xFFEA580C).withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: _DayNumberBadge(
            dayNumber: day.number,
            isToday: isToday,
            allDone: allDone,
            progress: progress,
          ),
          title: Row(
            children: [
              Text(
                isToday
                    ? 'Hari ${day.number} — Hari Ini'
                    : 'Hari ${day.number}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isToday ? const Color(0xFFEA580C) : Colors.black87,
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              if (allDone)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF059669),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Selesai',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  '$completedCount/$totalPassages bacaan selesai',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
            ],
          ),
          children: [
            // Passage list
            ...List.generate(day.passages.length, (passageIdx) {
              final passage = day.passages[passageIdx];
              final completed = state.isPassageCompleted(
                monthIdx,
                day.number,
                passageIdx,
              );
              final typeInfo = passageIdx < passageTypes.length
                  ? passageTypes[passageIdx]
                  : passageTypes[0];
              final typeColor = typeInfo['color'] as Color;
              final typeIcon = typeInfo['icon'] as IconData;
              final typeKey = typeInfo['key'] as String;
              final typeLabel = typeInfo['fullLabel'] as String;

              return InkWell(
                onTap: () {
                  if (passage.text.isEmpty) return;
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(ctx).padding.top + 40,
                      ),
                      child: ReadingBottomSheet(
                        reference: passage.text,
                        passageType: typeKey,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Passage type indicator
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(typeIcon, color: typeColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              typeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              passage.text.isNotEmpty ? passage.text : '—',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: passage.text.isEmpty
                                    ? Colors.grey[400]
                                    : completed
                                    ? Colors.grey[500]
                                    : Colors.black87,
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Read icon (tap to open)
                      if (passage.text.isNotEmpty)
                        Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      const SizedBox(width: 8),
                      // Checkbox
                      Transform.scale(
                        scale: 1.1,
                        child: Checkbox(
                          value: completed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          activeColor: typeColor,
                          side: BorderSide(color: Colors.grey[400]!),
                          onChanged: (_) => state.togglePassage(
                            monthIdx,
                            day.number,
                            passageIdx,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Complete all button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: FilledButton.icon(
                icon: Icon(allDone ? Icons.refresh : Icons.done_all, size: 18),
                onPressed: () => state.completeAllForDay(monthIdx, day.number),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: allDone
                      ? Colors.grey[300]
                      : const Color(0xFF1E3A8A),
                  foregroundColor: allDone ? Colors.grey[700] : Colors.white,
                ),
                label: Text(
                  allDone ? 'Hapus Semua Tanda' : 'Tandai Semua Selesai',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Day Number Badge ──────────────────────────────────────────────────────────
class _DayNumberBadge extends StatelessWidget {
  final int dayNumber;
  final bool isToday;
  final bool allDone;
  final double progress;

  const _DayNumberBadge({
    required this.dayNumber,
    required this.isToday,
    required this.allDone,
    required this.progress,
  });

  @override
  Widget build(Context context) {
    Color bgColor;
    Color textColor;
    if (allDone) {
      bgColor = const Color(0xFF059669);
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = const Color(0xFFEA580C);
      textColor = Colors.white;
    } else if (progress > 0) {
      bgColor = const Color(0xFF1E3A8A).withOpacity(0.15);
      textColor = const Color(0xFF1E3A8A);
    } else {
      bgColor = Colors.grey[100]!;
      textColor = Colors.grey[700]!;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: allDone
          ? const Icon(Icons.check, color: Colors.white, size: 20)
          : Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
    );
  }
}

