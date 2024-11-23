import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zametka_app/providers/NotesProvider%20.dart';
import 'package:zametka_app/screens/HomePage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zametka_app/screens/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Инициализация Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(
      'ru_RU', null); // Инициализация для русского языка

  // Оборачиваем приложение в MultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      theme: ThemeData.light(), // Светлая тема
      darkTheme: ThemeData.dark(), // Темная тема
      themeMode: ThemeMode.system, // Используем системный режим по умолчанию
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Проверяем, авторизован ли пользователь
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), // Отслеживаем состояние аутентификации
      builder: (context, snapshot) {
        // Если у нас нет данных о пользователе, значит не авторизован
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Индикатор загрузки
        }
        if (snapshot.hasData) {
          // Если пользователь авторизован, отправляем его на главный экран
          return NotesListScreen();
        } else {
          // Если пользователь не авторизован, показываем экран авторизации
          return LoginScreen();
        }
      },
    );
  }
}
