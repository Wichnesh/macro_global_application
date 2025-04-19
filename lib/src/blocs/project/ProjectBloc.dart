import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macro_global_test_app/src/model/ProjectModel.dart';

import 'ProjectEvent.dart';
import 'ProjectState.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final FirebaseFirestore firestore;

  ProjectBloc(this.firestore) : super(ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<SearchProjects>(_onSearchProjects);
    on<AddProject>(_onAddProject);
  }

  Future<void> _onLoadProjects(LoadProjects event, Emitter emit) async {
    emit(ProjectLoading());
    try {
      final collection = firestore.collection('projects');
      final snapshot = await collection.get();

      // If no projects found, add 3 dummy projects
      if (snapshot.docs.isEmpty) {
        final dummyProjects = [
          ProjectModel(
            id: '',
            name: 'AI Tyre Detector',
            description: 'Detect worn-out tyres with AI',
            peopleWorking: 4,
            projectedRevenue: {'Jan': 5000, 'Feb': 7000, 'Mar': 8500},
            imageUrl: null,
            videoUrl: null,
            latitude: 13.0827, // Chennai, Tamil Nadu
            longitude: 80.2707,
          ),
          ProjectModel(
            id: '',
            name: 'Fuel Efficiency Tracker',
            description: 'Track vehicle mileage and efficiency',
            peopleWorking: 3,
            projectedRevenue: {'Jan': 4000, 'Feb': 6000, 'Mar': 7500},
            imageUrl: null,
            videoUrl: null,
            latitude: 10.7905, // Coimbatore, Tamil Nadu
            longitude: 76.7046,
          ),
          ProjectModel(
            id: '',
            name: 'Battery Health Monitor',
            description: 'Monitor EV battery usage and health',
            peopleWorking: 5,
            projectedRevenue: {'Jan': 5500, 'Feb': 7200, 'Mar': 9000},
            imageUrl: null,
            videoUrl: null,
            latitude: 11.1271, // Tiruchirapalli, Tamil Nadu
            longitude: 78.6569,
          ),
        ];

        for (var project in dummyProjects) {
          await collection.add(project.toMap());
        }

        // Fetch again after adding
        final updatedSnapshot = await collection.get();
        final updatedProjects = updatedSnapshot.docs
            .map(
              (doc) => ProjectModel.fromMap(doc.id, doc.data()),
            )
            .toList();

        emit(ProjectLoaded(updatedProjects));
      } else {
        final projects = snapshot.docs
            .map(
              (doc) => ProjectModel.fromMap(doc.id, doc.data()),
            )
            .toList();

        emit(ProjectLoaded(projects));
      }
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  void _onSearchProjects(SearchProjects event, Emitter emit) {
    if (state is ProjectLoaded) {
      final all = (state as ProjectLoaded).projects;
      final filtered = all.where((p) => p.name.toLowerCase().contains(event.query.toLowerCase())).toList();
      emit(ProjectLoaded(filtered));
    }
  }

  Future<void> _onAddProject(AddProject event, Emitter emit) async {
    try {
      await firestore.collection('projects').add(event.project.toMap());
      add(LoadProjects()); // reload after adding
    } catch (e) {
      emit(ProjectError('Failed to add project'));
    }
  }
}
