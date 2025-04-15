import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_bloc.dart';
import '../logic/auth_event.dart';
import '../logic/auth_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool isLogin = true;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -550, end: -250).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final authBloc = context.read<AuthBloc>();
      if (isLogin) {
        authBloc.add(LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ));
      } else {
        authBloc.add(RegisterEvent(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ));
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: _animation.value,
                    left: -100,
                    child: CircleAvatar(
                      radius: 400,
                      backgroundColor: const Color.fromARGB(255, 237, 252, 249).withOpacity(0.5),
                    ),
                  ),
                  Positioned(
                    bottom: _animation.value,
                    left: -100,
                    child: CircleAvatar(
                      radius: 400,
                      backgroundColor: const Color.fromARGB(255, 232, 253, 249),
                    ),
                  ),
                ],
              );
            },
          ),
          
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is AuthAuthenticated) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 100,
                            errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.error, size: 100, color: Colors.red),
                          ),
                          const SizedBox(height: 20),
                          
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              isLogin ? "Sign In" : "Sign Up",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 16, 51),
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          if (!isLogin) ...[
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'User Name',
                                labelStyle: const TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFF00826C))),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF00826C))),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF00826C), width: 2)),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                          ],

                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.black),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF00826C))),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF00826C))),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF00826C), width: 2)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.black),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF00826C))),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF00826C))),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF00826C), width: 2)),
                              suffixIcon: IconButton(
                                icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() => _isObscure = !_isObscure);
                                },
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 10),

                          if (!isLogin) ...[
                            TextFormField(
                              controller: _passwordConfirmController,
                              obscureText: _isConfirmObscure,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                labelStyle: const TextStyle(color: Colors.black),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF00826C))),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF00826C))),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF00826C), width: 2)),
                                suffixIcon: IconButton(
                                  icon: Icon(_isConfirmObscure ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() => _isConfirmObscure = !_isConfirmObscure);
                                  },
                                ),
                              ),
                              validator: _validateConfirmPassword,
                            ),
                            const SizedBox(height: 30),
                          ],
                          
                          if (isLogin) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/forgot-password'),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: const Color(0xFF00826C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              isLogin ? 'Sign In' : 'Sign Up',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          Row(
                            children: const [
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                  height: 20,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('or', style: TextStyle(color: Colors.grey)),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                  height: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialButton(icon: Icons.email, iconColor: Colors.red),
                              const SizedBox(width: 10),
                              _buildSocialButton(icon: Icons.facebook, iconColor: Colors.blue),
                              const SizedBox(width: 10),
                              _buildSocialButton(icon: Icons.apple, iconColor: Colors.black),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLogin ? "Don't have an account? " : "Already have an account? ",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 85, 85, 85),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() => isLogin = !isLogin);
                                },
                                child: Text(
                                  isLogin ? "Sign Up" : "Sign In",
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 0, 16, 51),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required Color iconColor}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromARGB(68, 0, 0, 0), width: 2),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}