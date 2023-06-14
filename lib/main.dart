import 'package:erevna/Student_Screens/student_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_login/animated_login.dart';

import 'Student_Screens/students_main.dart';
import 'Supervisor_Screens/supervisor_main.dart';
import 'bloc_ob.dart';
import 'package:bloc/bloc.dart' as ds;
import 'blocs/auth_bloc/auth_bloc.dart';
import 'check_user_type.dart';
import 'root_screen.dart';

const String storageRefFbS = "gs://erevna-33ca0.appspot.com";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.josefinSansTextTheme(Theme.of(context)
            .textTheme
            .apply(fontSizeFactor: 1.2, fontSizeDelta: 2.0)),
        colorScheme: const ColorScheme.light(primary: Colors.blueGrey),
      ),
      home: RootScreen(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var authBloc = AuthBloc();
  @override
  void dispose() {
    super.dispose();
    authBloc.close();
  }

  LoginViewTheme get LoginTheme => LoginViewTheme(
        backgroundColor: Colors.blueGrey,
        formFieldBackgroundColor: Colors.white,
        formTitleStyle: const TextStyle(color: Colors.black),
        welcomeTitleStyle: const TextStyle(color: Colors.black),
        welcomeDescriptionStyle: const TextStyle(color: Colors.black),
        actionButtonStyle: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Colors.blueGrey.shade900)),
        changeActionButtonStyle: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Colors.blueGrey.shade900)),
        textFormStyle: const TextStyle(color: Colors.black),
      );
  LoginTexts get _loginTexts => LoginTexts(
      welcome: 'Welcome Back!',
      welcomeDescription: 'Returning to this website?',
      welcomeBack: 'Welcome!',
      welcomeBackDescription: 'Is this your first time on this website?',
      notHaveAnAccount: 'Create a new account',
      alreadyHaveAnAccount: 'Sign into your account');

  @override
  Widget build(BuildContext context) {
    return Material(
        child: BlocBuilder(
      bloc: authBloc,
      builder: (context, state) {
        if (state is AuthInitial) {
          return AnimatedLogin(
            onLogin: onLogin,
            onSignup: onSignup,
            onForgotPassword: onForgotPassword,
            loginDesktopTheme: LoginTheme,
            loginTexts: _loginTexts,
          );
        }

        if (state is AuthLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is AuthSuccess) {
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            ///yaay logged in pop to home
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const CheckUserTypeScreen()),
                (Route<dynamic> route) => false);
          });
        }
        return AnimatedLogin(
          onLogin: onLogin,
          onSignup: onSignup,
          onForgotPassword: onForgotPassword,
        );
      },
    ));
  }

  Future<String?> onLogin(LoginData? loginData) async {
    //my code here
    authBloc.add(LoginUser(loginData));
    return null;
  }

  Future<String?> onSignup(SignUpData? signUpData) async {
    authBloc.add(SignupUser(signUpData));
    //my code here
    return null;
  }

  Future<String?> onForgotPassword(String? ds) async {
    //my code here
    return null;
  }
}
