import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ObjectDetailSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const ObjectDetailSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final entries = data.entries.toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(entries.length, (index) {
          final entry = entries[index];
          final isLast = index == entries.length - 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                  color: colors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.value}',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.textPrimary,
                ),
              ),
              if (!isLast) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
              ],
            ],
          );
        }),
      ),
    );
  }
}
