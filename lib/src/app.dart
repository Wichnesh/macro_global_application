import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macro_global_test_app/src/screens/dashboard_screen.dart';
import 'package:macro_global_test_app/src/screens/signup_screen.dart';
import 'package:macro_global_test_app/src/service/task_service.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/task/task_bloc.dart';
import 'screens/login_screen.dart';
import 'service/auth_service.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(AuthService()),
        ),
        BlocProvider(
          create: (_) => TaskBloc(TaskService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Firebase Task App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: initialRoute,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/dashboard': (context) => const Dashboard(),
        },
      ),
    );
  }
}
