import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macro_global_test_app/src/screens/project_detail_screen.dart';

import '../blocs/project/ProjectBloc.dart';
import '../blocs/project/ProjectEvent.dart';
import '../blocs/project/ProjectState.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectBloc(FirebaseFirestore.instance)..add(LoadProjects()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Projects'),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.add),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => const AddProjectScreen()),
            //     );
            //   },
            // )
          ],
        ),
        body: const ProjectListView(),
      ),
    );
  }
}

class ProjectListView extends StatelessWidget {
  const ProjectListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (query) {
              context.read<ProjectBloc>().add(SearchProjects(query));
            },
            decoration: const InputDecoration(
              labelText: 'Search Projects',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<ProjectBloc, ProjectState>(
            builder: (context, state) {
              if (state is ProjectLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProjectLoaded) {
                if (state.projects.isEmpty) {
                  return const Center(child: Text('No projects found.'));
                }
                return ListView.builder(
                  itemCount: state.projects.length,
                  itemBuilder: (context, index) {
                    final project = state.projects[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(project.name),
                        subtitle: Text(project.description),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailScreen(project),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              } else if (state is ProjectError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
