import 'package:flutter/material.dart';
import '../services/bible_api_service.dart';

class ReadingBottomSheet extends StatefulWidget {
  final String reference;
  final String passageType;

  const ReadingBottomSheet({
    super.key,
    required this.reference,
    this.passageType = '',
  });

  @override
  State<ReadingBottomSheet> createState() => _ReadingBottomSheetState();
}

class _ReadingBottomSheetState extends State<ReadingBottomSheet> {
  double _fontSize = 18.0;

  static const Map<String, Map<String, dynamic>> _passageTypeInfo = {
    'PL': {'label': 'Perjanjian Lama', 'color': Color(0xFF1E3A8A), 'icon': Icons.history_edu},
    'PB': {'label': 'Perjanjian Baru', 'color': Color(0xFFEA580C), 'icon': Icons.auto_stories},
    'Mzm': {'label': 'Mazmur', 'color': Color(0xFF7C3AED), 'icon': Icons.music_note},
    'Ams': {'label': 'Amsal', 'color': Color(0xFF059669), 'icon': Icons.lightbulb_outline},
  };

  @override
  Widget build(BuildContext context) {
    final typeInfo = _passageTypeInfo[widget.passageType];
    final typeColor = (typeInfo?['color'] as Color?) ?? Theme.of(context).colorScheme.primary;
    final typeLabel = (typeInfo?['label'] as String?) ?? widget.passageType;
    final typeIcon = (typeInfo?['icon'] as IconData?) ?? Icons.menu_book;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: typeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (typeLabel.isNotEmpty)
                      Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: typeColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    Text(
                      widget.reference,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                  ],
                ),
              ),
              // Font size controls
              Row(
                children: [
                  _fontSizeButton(Icons.text_decrease, () {
                    setState(() => _fontSize = (_fontSize - 2).clamp(12.0, 28.0));
                  }),
                  const SizedBox(width: 4),
                  _fontSizeButton(Icons.text_increase, () {
                    setState(() => _fontSize = (_fontSize + 2).clamp(12.0, 28.0));
                  }),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 8),
          // Bible text
          Expanded(
            child: FutureBuilder<String?>(
              future: BibleApiService.getPassage(widget.reference),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: typeColor),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat ayat...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_outlined, size: 56, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat ayat.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Periksa koneksi internet Anda dan coba lagi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Text(
                      snapshot.data!,
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 1.8,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _fontSizeButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: Colors.grey[700]),
      ),
    );
  }
}
