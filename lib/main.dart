import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridehailing/bloc/auth/register_models.dart';
import 'package:ridehailing/testing.dart';
import 'package:ridehailing/view/auth/login_view.dart';
import 'package:ridehailing/bloc/auth/login_models.dart';
import 'package:ridehailing/view/main/main_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();

    return MaterialApp(
      title: 'ridehailingdriver',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: loginViewModel.checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data == true) {
            return MainView();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
