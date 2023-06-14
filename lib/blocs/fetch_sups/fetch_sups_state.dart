part of 'fetch_sups_bloc.dart';

abstract class FetchSupsState extends Equatable {
  const FetchSupsState();

  @override
  List<Object> get props => [];
}

class FetchSupsInitial extends FetchSupsState {}

class FetchSupsLoading extends FetchSupsState {}

class FetchSupsNoData extends FetchSupsState {}

class FetchSupsSuccess extends FetchSupsState {
  final List<UserModel>? userModelList;

  const FetchSupsSuccess(this.userModelList);
}
