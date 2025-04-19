import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/ProjectModel.dart';
import 'MapEvent.dart';
import 'MapState.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final FirebaseFirestore firestore;

  MapBloc(this.firestore) : super(MapInitial()) {
    on<LoadMapProjects>(_onLoadProjects);
  }

  Future<void> _onLoadProjects(LoadMapProjects event, Emitter emit) async {
    emit(MapLoading());
    try {
      final snapshot = await firestore.collection('projects').get();
      final projects = snapshot.docs.map((doc) => ProjectModel.fromMap(doc.id, doc.data())).toList();
      emit(MapLoaded(projects));
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }
}
