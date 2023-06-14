part of 'check_user_type_bloc.dart';

abstract class CheckUserTypeState extends Equatable {
  const CheckUserTypeState();

  @override
  List<Object> get props => [];
}

class CheckUserTypeInitial extends CheckUserTypeState {}

class CheckUserTypeLoading extends CheckUserTypeState {}

class CheckUserTypeSuccess extends CheckUserTypeState {}

class CheckUserTypeSetupAccount extends CheckUserTypeState {}

class CheckUserTypeSuccessSup extends CheckUserTypeState {}

class CheckUserTypeSuccessStudent extends CheckUserTypeState {}

class CheckUserTypeError extends CheckUserTypeState {}
