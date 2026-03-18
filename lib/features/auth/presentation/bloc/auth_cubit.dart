import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth_service.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  final String apiKey;
  final String collectionName;
  const AuthAuthenticated({required this.apiKey, required this.collectionName});
  @override
  List<Object?> get props => [apiKey, collectionName];
}

class AuthSaving extends AuthState {
  const AuthSaving();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial());

  void checkAuth() {
    if (_authService.isAuthenticated) {
      emit(AuthAuthenticated(
        apiKey: _authService.apiKey!,
        collectionName: _authService.collectionName!,
      ));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> saveCredentials({
    required String apiKey,
    required String collectionName,
  }) async {
    emit(const AuthSaving());
    try {
      await _authService.save(apiKey: apiKey, collectionName: collectionName);
      emit(AuthAuthenticated(apiKey: apiKey, collectionName: collectionName));
    } catch (e) {
      emit(const AuthError('Failed to save credentials.'));
    }
  }

  Future<void> logout() async {
    try {
      await _authService.clear();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(const AuthError('Failed to clear credentials.'));
    }
  }
}
