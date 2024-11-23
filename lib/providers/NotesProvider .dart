import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/Note.dart';

class NotesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение всех заметок для текущего пользователя
  List<Note> _notes = [];
  List<Note> get notes => _notes;

  List<Note> _filteredNotes = [];
  List<Note> get filteredNotes => _filteredNotes;

  void searchNotes(String query) {
    if (query.isEmpty) {
      _filteredNotes = _notes;
    } else {
      _filteredNotes = _notes.where((note) {
        final titleLower = note.title.toLowerCase();
        final contentLower = note.content.toLowerCase();
        final searchLower = query.toLowerCase();
        return titleLower.contains(searchLower) ||
            contentLower.contains(searchLower);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchNotes(String uid) async {
    try {
      final notesData = await FirebaseFirestore.instance
          .collection('notes')
          .doc(uid)
          .collection('userNotes')
          .get();

      _notes = notesData.docs
          .map((doc) => Note(
                id: doc.id,
                title: doc['title'],
                content: doc['content'],
                date: doc['date'],
              ))
          .toList();

      _filteredNotes = _notes; // Инициализация отфильтрованных заметок
      notifyListeners();
    } catch (error) {
      print('Error fetching notes: $error');
      throw error;
    }
  }

  // Добавление заметки
  Future<void> addNote(
      String userId, String title, String content, String date) async {
    final newNote = Note(
      id: _firestore
          .collection('notes')
          .doc(userId)
          .collection('userNotes')
          .doc()
          .id,
      title: title,
      content: content,
      date: date, // Добавляем дату
    );

    await _firestore
        .collection('notes') // Основная коллекция
        .doc(userId) // Документ ID пользователя
        .collection('userNotes') // Вложенная коллекция заметок
        .doc(newNote.id) // Документ ID заметки
        .set(newNote.toMap());

    notifyListeners();
    ;
  }

  Future<void> updateNote(String userId, String id, String title,
      String content, String date) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index >= 0) {
      await _firestore
          .collection('notes') // Основная коллекция
          .doc(userId) // Документ ID пользователя
          .collection('userNotes') // Вложенная коллекция заметок
          .doc(id)
          .update({
        'title': title,
        'content': content,
        'date': date,
      });
      _notes[index].title = title;
      _notes[index].content = content;
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id, String userId) async {
    await _firestore
        .collection('notes') // Основная коллекция
        .doc(userId) // Документ ID пользователя
        .collection('userNotes') // Вложенная коллекция заметок
        .doc(id)
        .delete();
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}
