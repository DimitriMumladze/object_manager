import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/auth_service.dart';
import 'core/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  final themeCubit = ThemeCubit();
  await Future.wait([authService.load(), themeCubit.load()]);
  runApp(ObjectManagerApp(authService: authService, themeCubit: themeCubit));
}
