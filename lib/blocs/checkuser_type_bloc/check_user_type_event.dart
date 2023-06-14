part of 'check_user_type_bloc.dart';

abstract class CheckUserTypeEvent extends Equatable {
  const CheckUserTypeEvent();

  @override
  List<Object> get props => [];
}

class CheckUserRole extends CheckUserTypeEvent {}

class UpdateUserData extends CheckUserTypeEvent {
  final UserModel? userModel;

  const UpdateUserData(this.userModel);
}
