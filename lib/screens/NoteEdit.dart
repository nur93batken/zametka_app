import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zametka_app/providers/NotesProvider%20.dart';
import 'package:zametka_app/screens/HomePage.dart';
import 'package:intl/intl.dart';

class NoteEditScreen extends StatefulWidget {
  final String? noteId;

  const NoteEditScreen({Key? key, this.noteId}) : super(key: key);

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid; // Это ID пользователя

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.noteId != null) {
      final note = Provider.of<NotesProvider>(context, listen: false)
          .notes
          .firstWhere((note) => note.id == widget.noteId);
      _titleController.text = note.title;
      _contentController.text = note.content;
    }
  }

  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  void dispose() {
    // Освобождаем ресурсы контроллеров
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.noteId == null ? 'Добавить заметку' : 'Обновить заметку'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              'assets/task.png',
              height: 80, // Укажите высоту
              width: 80, // Укажите ширину
              fit: BoxFit.contain, // Подгонка изображения
            ),
            const SizedBox(
              height: 24,
            ),
            TextField(
              controller: _titleController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Название',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Текст заметки',
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
                onPressed: () async {
                  final currentDate = DateFormat('EEEE - dd.MM.yyyy', 'ru_RU')
                      .format(DateTime.now()); // Форматируем дату
                  final formattedDate = capitalize(currentDate);

                  if (widget.noteId == null) {
                    if (_titleController.text.isNotEmpty &&
                        _contentController.text.isNotEmpty) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => NotesListScreen()),
                        (route) => false,
                      );
                      await notesProvider.addNote(
                        uid,
                        _titleController.text,
                        _contentController.text,
                        formattedDate, // Добавляем дату
                      );
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 6,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: const Offset(12, 26),
                                          blurRadius: 30,
                                          spreadRadius: 0,
                                          color: Colors.grey.withOpacity(.1)),
                                    ]),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Данные не заполнены",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        height: 3.5,
                                      ),
                                      Text("Заполните все поля",
                                          style: TextStyle(
                                              color: Colors.amber,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300)),
                                      SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    }
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => NotesListScreen()),
                      (route) => false,
                    );
                    await notesProvider.updateNote(
                      uid,
                      widget.noteId!,
                      _titleController.text,
                      _contentController.text,
                      formattedDate,
                    );
                  }
                },
                child: const Text(
                  'Сохранить',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
