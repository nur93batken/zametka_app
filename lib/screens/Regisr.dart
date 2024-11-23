import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zametka_app/screens/Login.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // Функция для регистрации
  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Регистрация пользователя с email и паролем
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // После успешной регистрации, можно направить пользователя на главный экран
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Registration successful!")));
    } catch (e) {
      // Отображаем ошибку
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
      appBar: AppBar(title: const Text('Регистрация')),
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
                      onPressed: _register,
                      child: const Text(
                        'Зарегистрироватся',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Если вы зарегистрирован?',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                      child: TextButton(
                          onPressed: () {
                            // Переход на экран Login
                            Navigator.pop(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoginScreen(),
                              ),
                            ); // Обновляем данные после возврата
                          },
                          child: const Text('Войти')))
                ],
              ),
      ),
    );
  }
}
