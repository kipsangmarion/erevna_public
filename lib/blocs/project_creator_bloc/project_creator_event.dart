part of 'project_creator_bloc.dart';

abstract class ProjectCreatorEvent extends Equatable {
  const ProjectCreatorEvent();

  @override
  List<Object> get props => [];
}

class StartProjectInit extends ProjectCreatorEvent {}

class StartProjectEvent extends ProjectCreatorEvent {
  final ProjectModel? projectModel;

  const StartProjectEvent(this.projectModel);
}

class StartProjectUpdate extends ProjectCreatorEvent {
  final ProjectModel? projectModel;

  const StartProjectUpdate(this.projectModel);
}
