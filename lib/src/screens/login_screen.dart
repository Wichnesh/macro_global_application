import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../service/biometric_auth.dart';
import '../service/storage_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _passwordError;
  bool _highlightGoogleButton = false;
  bool _showBiometric = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _checkBiometricAvailability();
  }

  void _checkBiometricAvailability() async {
    final isLoggedIn = await StorageService.isLoggedIn();

    if (isLoggedIn) {
      // Run after first frame so context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final success = await BiometricService.authenticate(context);
        if (success) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    setState(() {
      _emailError = (email.isEmpty || !email.contains('@')) ? 'Enter a valid email' : null;
    });
  }

  void _validatePassword() {
    final password = _passwordController.text.trim();
    setState(() {
      if (password.isEmpty) {
        _passwordError = 'Password required';
      } else if (password.length < 6) {
        _passwordError = 'Min 6 characters';
      } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
        _passwordError = 'Include at least one uppercase letter';
      } else if (!RegExp(r'\d').hasMatch(password)) {
        _passwordError = 'Include at least one number';
      } else {
        _passwordError = null;
      }
    });
  }

  void _showGoogleSignInWarning() {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: const Text("This email is already registered via Google. Please sign in with Google."),
      autoCloseDuration: const Duration(seconds: 4),
    );
    setState(() {
      _highlightGoogleButton = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state is Unauthenticated && state.message != null) {
            if (state.message!.contains('already registered via Google')) {
              _showGoogleSignInWarning();
            } else {
              toastification.show(
                context: context,
                type: ToastificationType.error,
                style: ToastificationStyle.fillColored,
                title: Text(state.message!),
                autoCloseDuration: const Duration(seconds: 4),
              );
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome !',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: _emailError,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: _passwordError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            _validateEmail();
                            _validatePassword();
                            if (_emailError == null && _passwordError == null) {
                              context.read<AuthBloc>().add(
                                    LoginRequested(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    ),
                                  );
                            }
                          },
                    child: state is AuthLoading ? const CircularProgressIndicator() : const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'OR',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 20.0,
                    ),
                    label: const Text('Sign in with Google'),
                    onPressed: () {
                      context.read<AuthBloc>().add(GoogleSignInRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _highlightGoogleButton ? Colors.orange.shade100 : Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(
                        color: _highlightGoogleButton ? Colors.orange : Colors.grey,
                        width: _highlightGoogleButton ? 2 : 1,
                      ),
                      elevation: _highlightGoogleButton ? 4 : 0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: const Text("Don't have an account? Sign up"),
                  ),
                  if (_showBiometric)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final success = await BiometricService.authenticate(context);
                          if (success) {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                        icon: const Icon(Icons.fingerprint, size: 26),
                        label: const Text(
                          'Unlock with Fingerprint',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
