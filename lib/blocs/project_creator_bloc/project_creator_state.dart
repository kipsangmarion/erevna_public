part of 'project_creator_bloc.dart';

abstract class ProjectCreatorState extends Equatable {
  const ProjectCreatorState();

  @override
  List<Object> get props => [];
}

class ProjectCreatorInitial extends ProjectCreatorState {}

class ProjectCreatorLoading extends ProjectCreatorState {}

class ProjectCreatorSuccess extends ProjectCreatorState {
  final String? projId;

  const ProjectCreatorSuccess(this.projId);
}
