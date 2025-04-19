import '../../model/ProjectModel.dart';

abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<ProjectModel> projects;

  MapLoaded(this.projects);
}

class MapError extends MapState {
  final String message;

  MapError(this.message);
}
