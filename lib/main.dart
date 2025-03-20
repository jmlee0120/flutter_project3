import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/nickname_setup_screen.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();



// main 함수 내부
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MeetupApp(),
    ),
  );
}

class MeetupApp extends StatelessWidget {
  const MeetupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'David C.',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Scaffold(
              backgroundColor: Color(0xFFDEEFFF),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // 로그인되어 있으면
          if (authProvider.isLoggedIn) {
            // 닉네임 설정 확인
            if (authProvider.hasNickname) {
              return const MainScreen();
            } else {
              return const NicknameSetupScreen();
            }
          }

          // 로그인되어 있지 않으면
          return const LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}