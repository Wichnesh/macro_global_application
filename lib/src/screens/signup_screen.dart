import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ValueNotifier<String?> _emailError = ValueNotifier(null);
  final ValueNotifier<String?> _passwordError = ValueNotifier(null);

  bool _obscurePassword = true;
  bool _highlightGoogleButton = false;

  void _showError(String message) {
    toastification.show(
      context: context,
      title: const Text('Error'),
      description: Text(message),
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
    );
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
  }

  void _submitForm() {
    _validateEmail();
    _validatePassword();

    if (_formKey.currentState!.validate() && _emailError.value == null && _passwordError.value == null) {
      context.read<AuthBloc>().add(
            SignUpRequested(
              emailController.text.trim(),
              passwordController.text.trim(),
              nameController.text.trim(),
              phoneController.text.trim(),
            ),
          );
    }
  }

  void _validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _emailError.value = 'Enter a valid email';
    } else {
      _emailError.value = null;
    }
  }

  void _validatePassword() {
    final password = passwordController.text.trim();
    if (password.length < 6) {
      _passwordError.value = 'Password must be 6+ characters';
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      _passwordError.value = 'Add at least one uppercase letter';
    } else if (!RegExp(r'\d').hasMatch(password)) {
      _passwordError.value = 'Add at least one number';
    } else {
      _passwordError.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter phone number' : null,
              ),
              ValueListenableBuilder<String?>(
                valueListenable: _emailError,
                builder: (context, error, child) => TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: error,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              ValueListenableBuilder<String?>(
                valueListenable: _passwordError,
                builder: (context, error, child) => TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: error,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        _obscurePassword = !_obscurePassword;
                        (context as Element).markNeedsBuild(); // 👈 without setState
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 10),
              Center(child: Text("or")),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Image.asset('assets/images/google_logo.png', height: 20),
                label: const Text("Sign Up with Google"),
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
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // go back to login
                },
                child: const Text("Already have an account? Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
