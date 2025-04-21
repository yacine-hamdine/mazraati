import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  final storage = FlutterSecureStorage();

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);

    on<AuthEvent>((event, emit) async {
      if (event is RegisterEvent || event is LoginEvent) {
        emit(AuthLoading());
        try {
          final user = await authRepository.login(
            event.props[0].toString(),
            event.props[1].toString()
          );
          emit(AuthAuthenticated(user));
        } catch (e) {
          emit(AuthError(e.toString()));
        }
      } else if (event is LogoutEvent) {
        emit(AuthLoggedOut());
      }
    });
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register(
        event.username,
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(
        event.email,
        event.password,
      );

      final token = user.token;

      if (token != null) {
        await storage.write(key: 'jwt_token', value: token);
        ApiClient.setToken(token); // ← Set bearer token globally
      }

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Perform logout logic (clear tokens, etc.)
    emit(AuthLoggedOut());
  }
}
