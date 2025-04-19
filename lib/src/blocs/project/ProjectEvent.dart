import '../../model/ProjectModel.dart';

abstract class ProjectEvent {}

class LoadProjects extends ProjectEvent {}

class SearchProjects extends ProjectEvent {
  final String query;
  SearchProjects(this.query);
}

class AddProject extends ProjectEvent {
  final ProjectModel project;
  AddProject(this.project);
}
