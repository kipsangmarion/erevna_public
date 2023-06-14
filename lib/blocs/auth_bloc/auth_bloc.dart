import 'package:animated_login/animated_login.dart';
import 'package:bloc/bloc.dart';
import 'package:erevna/helpers/firebase_helper.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    /// [SignupUser] to sign up suer
    on<SignupUser>((event, emit) async {
      emit.call(AuthLoading());
      var res = await firebaseHelper.signupUser(
          displayName: event.signUpData!.name,
          email: event.signUpData!.email,
          password: event.signUpData!.password);
      if (res != null) {
        emit.call(AuthSuccess());
      } else {
        emit.call(AuthInitial());
      }
    });

    /// [LoginUser] to sign up suer
    on<LoginUser>((event, emit) async {
      emit.call(AuthLoading());
      var res = await firebaseHelper.singInUser(
          email: event.loginData!.email, password: event.loginData!.password);
      if (res != null) {
        emit.call(AuthSuccess());
      } else {
        emit.call(AuthInitial());
      }
    });
  }
}
