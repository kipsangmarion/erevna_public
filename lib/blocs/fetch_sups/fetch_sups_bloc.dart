import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erevna/helpers/firebase_helper.dart';
import 'package:erevna/models/user/user_model.dart';

part 'fetch_sups_event.dart';
part 'fetch_sups_state.dart';

class FetchSupsBloc extends Bloc<FetchSupsEvent, FetchSupsState> {
  FetchSupsBloc() : super(FetchSupsInitial()) {
    on<FetchALlSUpsEvent>((event, emit) async {
      try {
        emit.call(FetchSupsLoading());
        var res = await firebaseHelper.fetchSupervisors();
        if (res!.isNotEmpty) {
          emit.call(FetchSupsSuccess(res));
        } else {
          emit.call(FetchSupsNoData());
        }
      } catch (e) {
        emit.call(FetchSupsInitial());
      }
    });
  }
}
