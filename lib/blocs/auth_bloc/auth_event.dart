part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class SignupUser extends AuthEvent {
  final SignUpData? signUpData;

  SignupUser(this.signUpData);
}

class LoginUser extends AuthEvent {
  final LoginData? loginData;

  LoginUser(this.loginData);
}
