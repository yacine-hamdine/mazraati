import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_bloc.dart';
import '../logic/auth_event.dart';
import '../logic/auth_state.dart';

// Import your custom widgets
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/loading_indicator.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true; // Toggle between login & register
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Bienvenue, ${state.user.username}!')),
            );
            // Navigate to home or wherever:
            // Navigator.pushReplacementNamed(context, '/home');
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6AB187), Color(0xFFEEF4ED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Main Card
              Center(
                child: SingleChildScrollView(
                  child: Card(
                    margin: const EdgeInsets.all(24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo or Header
                          Image.asset(
                            'assets/images/logo.png', // Your logo
                            height: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isLogin ? 'Connexion' : 'Inscription',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),

                          // Fields
                          if (!isLogin)
                            CustomTextField(
                              controller: _usernameController,
                              labelText: 'Nom d’utilisateur',
                              prefixIcon: Icons.person,
                            ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            prefixIcon: Icons.email,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _passwordController,
                            labelText: 'Mot de passe',
                            obscureText: true,
                            prefixIcon: Icons.lock,
                          ),
                          const SizedBox(height: 24),

                          // Submit Button
                          state is AuthLoading
                              ? const LoadingIndicator()
                              : ElevatedButton(
                                  onPressed: () {
                                    if (isLogin) {
                                      authBloc.add(
                                        LoginEvent(
                                          email:
                                              _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                        ),
                                      );
                                    } else {
                                      authBloc.add(
                                        RegisterEvent(
                                          username:
                                              _usernameController.text.trim(),
                                          email:
                                              _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 50,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(isLogin ? 'Se connecter' : 'S’inscrire'),
                                ),
                          const SizedBox(height: 16),

                          // Toggle Login/Register
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                            child: Text(
                              isLogin
                                  ? 'Vous n’avez pas de compte ? Inscrivez-vous'
                                  : 'Vous avez déjà un compte ? Connectez-vous',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}