part of 'fetch_sups_bloc.dart';

abstract class FetchSupsEvent extends Equatable {
  const FetchSupsEvent();

  @override
  List<Object> get props => [];
}

class FetchALlSUpsEvent extends FetchSupsEvent {}
