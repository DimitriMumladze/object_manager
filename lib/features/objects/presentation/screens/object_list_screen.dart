import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/object_list_bloc.dart';
import '../bloc/object_list_event.dart';
import '../bloc/object_list_state.dart';
import '../widgets/object_card.dart';

class ObjectListScreen extends StatefulWidget {
  const ObjectListScreen({super.key});

  @override
  State<ObjectListScreen> createState() => _ObjectListScreenState();
}

class _ObjectListScreenState extends State<ObjectListScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : const Text('Objects'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.search, color: colors.textSecondary),
              onPressed: () => setState(() => _isSearching = true),
            ),
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.close, color: colors.textSecondary),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
                context.read<ObjectListBloc>().add(const SearchObjects(''));
              },
            ),
          if (!_isSearching)
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                return IconButton(
                  icon: Icon(
                    authState is AuthAuthenticated
                        ? Icons.verified_user
                        : Icons.settings,
                    color: authState is AuthAuthenticated
                        ? colors.success
                        : colors.textSecondary,
                    size: 22,
                  ),
                  tooltip: 'API Settings',
                  onPressed: () => context.go('/settings'),
                );
              },
            ),
          if (!_isSearching)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colors.textSecondary),
              onSelected: (value) {
                if (value == 'refresh') {
                  context.read<ObjectListBloc>().add(const RefreshObjects());
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
              ],
            ),
        ],
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.divider),
        ),
      ),
      body: BlocBuilder<ObjectListBloc, ObjectListState>(
        builder: (context, state) {
          if (state is ObjectListLoading) {
            return const ShimmerLoading();
          }

          if (state is ObjectListError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<ObjectListBloc>().add(const LoadObjects()),
            );
          }

          if (state is ObjectListLoaded) {
            if (state.objects.isEmpty) {
              return EmptyState(
                onCreate: () => context.go('/objects/create'),
              );
            }

            if (state.filteredObjects.isEmpty && state.searchQuery.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 56,
                      color: colors.textTertiary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No results for "${state.searchQuery}"',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: colors.primary,
              onRefresh: () async {
                context.read<ObjectListBloc>().add(const RefreshObjects());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.screenPadding),
                itemCount: state.filteredObjects.length,
                itemBuilder: (context, index) {
                  final object = state.filteredObjects[index];
                  return ObjectCard(
                    object: object,
                    onTap: () => context.go('/objects/${object.id}'),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<ObjectListBloc, ObjectListState>(
        builder: (context, state) {
          if (state is ObjectListLoaded && state.objects.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () => context.go('/objects/create'),
              child: const Icon(Icons.add, size: 24),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search objects...',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      onChanged: (query) {
        context.read<ObjectListBloc>().add(SearchObjects(query));
      },
    );
  }
}
