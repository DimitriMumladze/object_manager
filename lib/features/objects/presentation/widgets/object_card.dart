import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/api_object_model.dart';

class ObjectCard extends StatelessWidget {
  final ApiObject object;
  final VoidCallback onTap;

  const ObjectCard({super.key, required this.object, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.cardGap),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          highlightColor: Colors.transparent,
          splashColor: colors.divider,
          child: Container(
            padding: const EdgeInsets.all(AppConstants.cardPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: colors.divider, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Hero(
                        tag: 'object-name-${object.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            object.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: colors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${object.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
                if (object.data != null && object.data!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDataChips(colors),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataChips(AppColors colors) {
    final entries = object.data!.entries.take(3).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors.chipBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '${entry.value}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.chipText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}
