import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/services/auth_service.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/screens/settings_screen.dart';
import 'features/objects/data/repositories/object_repository.dart';
import 'features/objects/presentation/bloc/object_list_bloc.dart';
import 'features/objects/presentation/bloc/object_list_event.dart';
import 'features/objects/presentation/bloc/object_detail_cubit.dart';
import 'features/objects/presentation/bloc/object_form_cubit.dart';
import 'features/objects/presentation/screens/splash_screen.dart';
import 'features/objects/presentation/screens/object_list_screen.dart';
import 'features/objects/presentation/screens/object_detail_screen.dart';
import 'features/objects/presentation/screens/object_form_screen.dart';
import 'features/objects/data/models/api_object_model.dart';

class ObjectManagerApp extends StatefulWidget {
  final AuthService authService;
  final ThemeCubit themeCubit;

  const ObjectManagerApp({super.key, required this.authService, required this.themeCubit});

  @override
  State<ObjectManagerApp> createState() => _ObjectManagerAppState();
}

class _ObjectManagerAppState extends State<ObjectManagerApp> {
  late final ObjectRepository _repository;
  late final ObjectListBloc _objectListBloc;
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _repository = ObjectRepository(authService: widget.authService);
    _objectListBloc = ObjectListBloc(repository: _repository);
    _authCubit = AuthCubit(authService: widget.authService)..checkAuth();

    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/objects',
          builder: (context, state) => const ObjectListScreen(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => BlocProvider(
                create: (_) => ObjectFormCubit(repository: _repository),
                child: const ObjectFormScreen(),
              ),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return BlocProvider(
                  create: (_) =>
                      ObjectDetailCubit(repository: _repository)..loadObject(id),
                  child: ObjectDetailScreen(objectId: id),
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final object = state.extra as ApiObject?;
                    final id = state.pathParameters['id']!;

                    return BlocProvider(
                      create: (_) => ObjectFormCubit(repository: _repository),
                      child: _EditObjectLoader(
                        objectId: id,
                        existingObject: object,
                        repository: _repository,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _objectListBloc.close();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _objectListBloc..add(const LoadObjects())),
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: widget.themeCubit),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // When auth changes, refresh the repository and reload objects
          _repository.refreshAuth();
          _objectListBloc.add(const RefreshObjects());
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'ObjectManager',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}

class _EditObjectLoader extends StatefulWidget {
  final String objectId;
  final ApiObject? existingObject;
  final ObjectRepository repository;

  const _EditObjectLoader({
    required this.objectId,
    this.existingObject,
    required this.repository,
  });

  @override
  State<_EditObjectLoader> createState() => _EditObjectLoaderState();
}

class _EditObjectLoaderState extends State<_EditObjectLoader> {
  ApiObject? _object;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.existingObject != null) {
      _object = widget.existingObject;
    } else {
      _loadObject();
    }
  }

  Future<void> _loadObject() async {
    setState(() => _loading = true);
    try {
      final obj = await widget.repository.getObjectById(widget.objectId);
      if (mounted) setState(() { _object = obj; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load object'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Object')),
        body: Center(child: Text(_error!)),
      );
    }
    return ObjectFormScreen(existingObject: _object);
  }
}
