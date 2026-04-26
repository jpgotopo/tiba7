import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart' show Share;
import '../providers/reading_state.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ReadingState>(
        builder: (context, state, child) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalDays = state.totalDaysInYear;
          final completedDays = state.completedDaysCount;
          final globalPercent = state.completionPercentage;
          final monthPercent = state.currentMonthCompletionPercentage;
          final monthTotalDays = state.selectedMonth.days.length;
          final monthCompletedDays = state.completedDaysInCurrentMonth;
          final totalPassagesRead = completedDays * 4;

          return CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 110,
                backgroundColor: const Color(0xFF1E3A8A),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    onPressed: () => _shareProgress(context, state),
                    tooltip: 'Bagikan progres',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFFEA580C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  title: const Text(
                    'Statistik Bacaan',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 14),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ── Quick Stats Row ────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _QuickStatCard(
                            icon: Icons.local_fire_department,
                            iconColor: Colors.orange,
                            value: '${state.currentStreak}',
                            label: 'Streak\nSaat Ini',
                            bgColor: Colors.orange.withValues(alpha: 0.08),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickStatCard(
                            icon: Icons.emoji_events,
                            iconColor: const Color(0xFFD97706),
                            value: '${state.bestStreak}',
                            label: 'Streak\nTerbaik',
                            bgColor: const Color(0xFFD97706).withValues(alpha: 0.08),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickStatCard(
                            icon: Icons.menu_book,
                            iconColor: const Color(0xFF1E3A8A),
                            value: '$completedDays',
                            label: 'Hari\nSelesai',
                            bgColor: const Color(0xFF1E3A8A).withValues(alpha: 0.06),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickStatCard(
                            icon: Icons.auto_stories,
                            iconColor: const Color(0xFF7C3AED),
                            value: '$totalPassagesRead',
                            label: 'Bacaan\nDibaca',
                            bgColor: const Color(0xFF7C3AED).withValues(alpha: 0.06),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickStatCard(
                            icon: Icons.calendar_today,
                            iconColor: const Color(0xFF059669),
                            value: '${(state.completionPercentage).toStringAsFixed(0)}%',
                            label: 'Progress\nTahunan',
                            bgColor: const Color(0xFF059669).withValues(alpha: 0.06),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickStatCard(
                            icon: Icons.today,
                            iconColor: const Color(0xFFEA580C),
                            value: '${state.completedDaysInCurrentMonth}',
                            label: 'Hari Ini\nBulan Ini',
                            bgColor: const Color(0xFFEA580C).withValues(alpha: 0.06),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Annual Progress ────────────────────────────────
                    _buildCircularProgressCard(
                      context,
                      title: 'Kemajuan Tahunan',
                      subtitle: '$completedDays dari $totalDays hari dibaca',
                      percent: globalPercent,
                      color: const Color(0xFF1E3A8A),
                    ),
                    const SizedBox(height: 12),

                    // ── Monthly Progress ───────────────────────────────
                    _buildCircularProgressCard(
                      context,
                      title: 'Bulan Ini: ${state.selectedMonth.name}',
                      subtitle: '$monthCompletedDays dari $monthTotalDays hari dibaca',
                      percent: monthPercent,
                      color: const Color(0xFFEA580C),
                    ),
                    const SizedBox(height: 20),

                    // ── Monthly Breakdown ─────────────────────────────
                    Text(
                      'Kemajuan Per Bulan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _MonthlyBreakdownCard(state: state),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _shareProgress(BuildContext context, ReadingState state) {
    final pct = state.completionPercentage.toStringAsFixed(1);
    final monthPct = state.currentMonthCompletionPercentage.toStringAsFixed(1);
    final text = '''📖 Progres Bacaan Alkitab Saya — Tiba7

🔥 Streak saat ini: ${state.currentStreak} hari
🏆 Streak terbaik: ${state.bestStreak} hari
✅ Hari selesai: ${state.completedDaysCount} dari ${state.totalDaysInYear} hari
📅 Progress tahunan: $pct%
📆 Bulan ini (${state.selectedMonth.name}): $monthPct%

Yuk baca Alkitab setiap hari bersama Tiba7! 🙏''';
    Share.share(text);
  }

  Widget _buildCircularProgressCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double percent,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 9,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                  Text(
                    '${percent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 6,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Stat Card ───────────────────────────────────────────────────────────
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color bgColor;

  const _QuickStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3),
          ),
        ],
      ),
    );
  }
}

// ── Monthly Breakdown Card ────────────────────────────────────────────────────
class _MonthlyBreakdownCard extends StatelessWidget {
  final ReadingState state;

  const _MonthlyBreakdownCard({required this.state});

  static const List<String> _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(12, (i) {
            final month = state.months[i];
            int completed = 0;
            for (int d = 1; d <= month.days.length; d++) {
              bool allDone = true;
              for (int p = 0; p < 4; p++) {
                if (!state.isPassageCompleted(i, d, p)) {
                  allDone = false;
                  break;
                }
              }
              if (allDone) completed++;
            }
            final total = month.days.length;
            final pct = total > 0 ? completed / total : 0.0;
            final isSelected = i == state.selectedMonthIndex;
            final now = DateTime.now();
            final isPast = i < now.month - 1;
            final isCurrent = i == now.month - 1;

            Color barColor;
            if (pct >= 1.0) {
              barColor = const Color(0xFF059669);
            } else if (isCurrent) {
              barColor = const Color(0xFFEA580C);
            } else if (isPast && pct > 0) {
              barColor = const Color(0xFF1E3A8A).withValues(alpha: 0.7);
            } else {
              barColor = const Color(0xFF1E3A8A);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      _shortMonths[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFFEA580C) : Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '$completed/$total',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
