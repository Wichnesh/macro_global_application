import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/map/MapBloc.dart';
import '../blocs/project/ProjectBloc.dart';
import '../blocs/project/ProjectEvent.dart';
import '../screens/project_screen_ui.dart';
import '../service/ChartScreen.dart';
import 'MapScreen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ProjectScreen(),
    const MapScreen(),
    const ChartScreen(), // ✅ Chart tab added here
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProjectBloc>(
          create: (_) => ProjectBloc(FirebaseFirestore.instance)..add(LoadProjects()),
        ),
        BlocProvider<MapBloc>(
          create: (_) => MapBloc(FirebaseFirestore.instance),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.pushReplacementNamed(context, '/login');
              },
            )
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blue,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Charts'),
          ],
        ),
      ),
    );
  }
}
