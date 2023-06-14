import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erevna/helpers/firebase_helper.dart';
import 'package:erevna/models/project/project_model.dart';

part 'project_creator_event.dart';
part 'project_creator_state.dart';

class ProjectCreatorBloc
    extends Bloc<ProjectCreatorEvent, ProjectCreatorState> {
  ProjectCreatorBloc() : super(ProjectCreatorInitial()) {
    on<StartProjectEvent>((event, emit) async {
      try {
        emit.call(ProjectCreatorLoading());
        var res = await firebaseHelper.createAProject(
            projectModel: event.projectModel);
        emit.call(ProjectCreatorSuccess(res!));
      } catch (e) {
        log(e.toString());
        emit.call(ProjectCreatorInitial());
      }
    });

    on<StartProjectInit>((event, emit) async {
      emit.call(ProjectCreatorInitial());
    });

    on<StartProjectUpdate>((event, emit) async {
      try {
        emit.call(ProjectCreatorLoading());
        var res = await firebaseHelper.upDateProject(
            projectModel: event.projectModel);
        emit.call(ProjectCreatorSuccess(res!));
      } catch (e) {
        log(e.toString());
        emit.call(ProjectCreatorInitial());
      }
    });
  }
}
