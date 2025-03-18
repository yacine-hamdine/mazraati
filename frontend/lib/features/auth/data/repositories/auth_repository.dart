import '../models/user_model.dart';
import '../providers/auth_api_provider.dart';

class AuthRepository {
  final AuthApiProvider _authApiProvider = AuthApiProvider();

  Future<UserModel> register(
    String username,
    String email,
    String password,
  ) {
    return _authApiProvider.register(
      username: username,
      email: email,
      password: password,
    );
  }

  Future<UserModel> login(
    String email,
    String password,
  ) {
    return _authApiProvider.login(
      email: email,
      password: password,
    );
  }
}
