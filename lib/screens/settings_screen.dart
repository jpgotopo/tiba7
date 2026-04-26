import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_state.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await NotificationService().getSavedSettings();
    setState(() {
      _enabled = settings.enabled;
      _selectedTime = settings.time;
      _loading = false;
    });
  }

  Future<void> _toggleEnabled(bool value) async {
    // Update optimistically so the switch doesn't snap back
    setState(() => _enabled = value);

    if (value) {
      final granted = await NotificationService().requestPermission();
      if (!granted) {
        // Revert if permission denied
        setState(() => _enabled = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin notifikasi ditolak'),
            ),
          );
        }
        return;
      }
      await NotificationService().scheduleDailyReminder(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      );
    } else {
      await NotificationService().cancelReminder();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              secondary: Color(0xFFEA580C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() => _selectedTime = picked);
    if (_enabled) {
      await NotificationService().scheduleDailyReminder(
        hour: picked.hour,
        minute: picked.minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
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
              ),
              title: const Text(
                'Pengaturan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 14),
            ),
          ),
          SliverToBoxAdapter(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(title: 'Notifikasi'),
                        const SizedBox(height: 8),
                        Card(
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text(
                                  'Pengingat harian',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: const Text(
                                  'Terima pengingat setiap hari untuk membaca Alkitab',
                                ),
                                value: _enabled,
                                onChanged: _toggleEnabled,
                                activeColor: const Color(0xFF1E3A8A),
                                secondary: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                              ),
                              if (_enabled) ...[
                                const Divider(height: 1, indent: 72),
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  leading: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEA580C).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.access_time,
                                      color: Color(0xFFEA580C),
                                    ),
                                  ),
                                  title: const Text(
                                    'Waktu pengingat',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    _selectedTime.format(context),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  trailing: TextButton(
                                    onPressed: _pickTime,
                                    child: const Text('Ubah'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _SectionHeader(title: 'Tampilan'),
                        const SizedBox(height: 8),
                        Card(
                          child: Consumer<ReadingState>(
                            builder: (context, state, _) => SwitchListTile(
                              title: const Text(
                                'Mode Gelap',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text('Tampilan gelap untuk malam hari'),
                              value: state.darkMode,
                              onChanged: (_) => state.toggleDarkMode(),
                              activeColor: const Color(0xFF1E3A8A),
                              secondary: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.dark_mode_outlined,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_enabled)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Kamu akan menerima pengingat setiap hari pukul ${_selectedTime.format(context)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
