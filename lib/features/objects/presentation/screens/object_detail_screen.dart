import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/error_view.dart';
import '../bloc/object_detail_cubit.dart';
import '../bloc/object_list_bloc.dart';
import '../bloc/object_list_event.dart';
import '../widgets/object_detail_section.dart';
import 'package:shimmer/shimmer.dart';

class ObjectDetailScreen extends StatelessWidget {
  final String objectId;

  const ObjectDetailScreen({super.key, required this.objectId});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/objects'),
        ),
        title: const Text(
          'Object Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.divider),
        ),
      ),
      body: BlocConsumer<ObjectDetailCubit, ObjectDetailState>(
        listener: (context, state) {
          if (state is ObjectDeleted) {
            context.read<ObjectListBloc>().add(const RefreshObjects());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Object deleted successfully'),
                backgroundColor: colors.success,
                duration: AppConstants.snackBarDuration,
              ),
            );
            context.go('/objects');
          }
        },
        builder: (context, state) {
          if (state is ObjectDetailLoading) {
            return _buildShimmer(colors);
          }

          if (state is ObjectDetailError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ObjectDetailCubit>().loadObject(objectId),
            );
          }

          if (state is ObjectDetailLoaded) {
            final object = state.object;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.divider, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'object-name-${object.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              object.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ID: ${object.id}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (object.data != null && object.data!.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.sectionSpacing),
                    Text(
                      'SPECIFICATIONS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ObjectDetailSection(data: object.data!),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(
                        '/objects/${object.id}/edit',
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Object'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(
                            color: colors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete Object'),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final colors = AppColors.of(context);
    final cubit = context.read<ObjectDetailCubit>();
    final state = cubit.state;
    final name = state is ObjectDetailLoaded ? state.object.name : '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline,
                  size: 28, color: colors.error),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete Object?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone. "$name" will be permanently removed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: colors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel',
                style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.deleteObject(objectId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(AppColors colors) {
    return Shimmer.fromColors(
      baseColor: colors.shimmerBase,
      highlightColor: colors.shimmerHighlight,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),
            Container(width: 120, height: 12, color: Colors.white),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
