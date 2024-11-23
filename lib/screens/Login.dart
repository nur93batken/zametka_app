import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zametka_app/screens/HomePage.dart';
import 'package:zametka_app/screens/Regisr.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // Функция для авторизации
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Вход с использованием email и пароля
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // После успешного входа, переходим на главный экран
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NotesListScreen()),
      );
    } catch (e) {
      // Показ ошибки в случае неудачи
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/addfriend.png',
                      height: 64, // Укажите высоту
                      width: 64, // Укажите ширину
                      fit: BoxFit.contain, // Подгонка изображения
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Пароль',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text(
                        'Войти',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Если вы не зарегистрирован?',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                      child: TextButton(
                          onPressed: () {
                            // Переход на экран редактирования
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegistrationScreen(),
                              ),
                            ); // Обновляем данные после возврата
                          },
                          child: const Text('Зарегистрироватся')))
                ],
              ),
      ),
    );
  }
}
