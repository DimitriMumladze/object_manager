import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../objects/presentation/bloc/object_list_bloc.dart';
import '../../../objects/presentation/bloc/object_list_event.dart';
import '../bloc/auth_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _collectionController = TextEditingController();
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) {
      _apiKeyController.text = state.apiKey;
      _collectionController.text = state.collectionName;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _collectionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().saveCredentials(
          apiKey: _apiKeyController.text.trim(),
          collectionName: _collectionController.text.trim(),
        );
  }

  void _logout() {
    context.read<AuthCubit>().logout();
    _apiKeyController.clear();
    _collectionController.clear();
  }

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
          'API Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.divider),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<ObjectListBloc>().add(const RefreshObjects());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Credentials saved!'),
                backgroundColor: colors.success,
                duration: AppConstants.snackBarDuration,
              ),
            );
            context.go('/objects');
          }
          if (state is AuthUnauthenticated) {
            context.read<ObjectListBloc>().add(const RefreshObjects());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Credentials cleared. Using public API.'),
                backgroundColor: colors.warning,
                duration: AppConstants.snackBarDuration,
              ),
            );
            context.go('/objects');
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme toggle
                _buildThemeSelector(colors),
                const SizedBox(height: 24),

                // Info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Enter your API key and collection name to use authenticated endpoints. '
                          'This lets you create, edit, and delete objects in your own collection.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.primary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Status indicator
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isAuth = state is AuthAuthenticated;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isAuth
                            ? colors.success.withValues(alpha: 0.1)
                            : colors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isAuth ? colors.success : colors.warning,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isAuth ? Icons.check_circle : Icons.public,
                            color: isAuth ? colors.success : colors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAuth ? 'Authenticated Mode' : 'Public Mode',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isAuth ? colors.success : colors.warning,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                Text(
                  'API Key',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  decoration: InputDecoration(
                    hintText: 'Enter your API key',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                        color: colors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureApiKey = !_obscureApiKey),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'API key is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Collection Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _collectionController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. products, devices, my-items',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Collection name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isSaving = state is AuthSaving;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : _save,
                        icon: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.key, size: 20),
                        label: Text(isSaving ? 'Saving...' : 'Save Credentials'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is! AuthAuthenticated) {
                      return const SizedBox.shrink();
                    }
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Clear Credentials (Switch to Public)'),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.error,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(AppColors colors) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.divider, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildThemeOption(
                    colors: colors,
                    icon: Icons.light_mode,
                    label: 'Light',
                    isSelected: themeMode == ThemeMode.light,
                    onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.light),
                  ),
                  const SizedBox(width: 8),
                  _buildThemeOption(
                    colors: colors,
                    icon: Icons.dark_mode,
                    label: 'Dark',
                    isSelected: themeMode == ThemeMode.dark,
                    onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.dark),
                  ),
                  const SizedBox(width: 8),
                  _buildThemeOption(
                    colors: colors,
                    icon: Icons.settings_suggest,
                    label: 'System',
                    isSelected: themeMode == ThemeMode.system,
                    onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required AppColors colors,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colors.primary : colors.divider,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : colors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
