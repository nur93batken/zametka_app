import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zametka_app/providers/NotesProvider%20.dart';
import 'package:zametka_app/screens/Login.dart';
import 'package:zametka_app/screens/NoteEdit.dart';

class NotesListScreen extends StatefulWidget {
  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  late Future<void> _fetchNotesFuture;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchNotesFuture =
        Provider.of<NotesProvider>(context, listen: false).fetchNotes(uid);
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Переход на экран Login
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Выйти'),
            content: const Text('Вы хотите выйти?'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(),
                    ),
                  ); // Перенаправление на экран входа
                },
                child: const Text('Да'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Нет'),
              )
            ],
          );
        },
      );
    } catch (error) {
      print("Ошибка при выходе: $error");
      // Можно добавить показ сообщения об ошибке
    }
  }

  Future<void> _refreshNotes() async {
    await Provider.of<NotesProvider>(context, listen: false).fetchNotes(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Поиск заметок...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (query) {
            Provider.of<NotesProvider>(context, listen: false)
                .searchNotes(query);
          },
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await _logout(); // Вызов метода выхода
              },
              icon: const Icon(Icons.logout)),
        ],
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
        future: _fetchNotesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки данных'));
          } else {
            return Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                return notesProvider.filteredNotes.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/notes.png',
                            height: 100, // Укажите высоту
                            width: 100, // Укажите ширину
                            fit: BoxFit.contain, // Подгонка изображения
                          ),
                          const Center(
                            child: Text('Нет заметок'),
                          ),
                        ],
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshNotes,
                        child: ListView.builder(
                          itemCount: notesProvider.filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = notesProvider.filteredNotes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.date,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                    Text(
                                      note.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                    Text(note.content),
                                    const SizedBox(height: 16),
                                    const Divider(
                                      color: Color.fromARGB(255, 219, 217, 217),
                                      thickness: 1,
                                      indent: 0,
                                      endIndent: 0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => NoteEditScreen(
                                                    noteId: note.id),
                                              ),
                                            );
                                            _refreshNotes();
                                          },
                                          label: const Text(
                                            'Редактировать',
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext ctx) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Удалить заметку'),
                                                  content: const Text(
                                                      'Вы хотите удалить?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        await notesProvider
                                                            .deleteNote(
                                                                note.id, uid);
                                                        _refreshNotes();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text('Да'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text('Нет'),
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          label: const Text(
                                            'Удалить',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NoteEditScreen(),
            ),
          );
          _refreshNotes();
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
