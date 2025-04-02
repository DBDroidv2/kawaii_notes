import 'dart:math'; // Import for min function

import 'package:flutter/foundation.dart'; // Needed for ValueListenable
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kawaii_notes/src/models/folder.dart';
import 'package:kawaii_notes/src/models/note.dart';
import 'package:uuid/uuid.dart';

const String notesBoxName = 'notes';
const String foldersBoxName = 'folders';

class HiveService {
  final Uuid _uuid = const Uuid(); // For generating unique IDs

  // --- Box Initialization ---

  Future<void> openBoxes() async {
    await Hive.openBox<Note>(notesBoxName);
    await Hive.openBox<Folder>(foldersBoxName);
  }

  Box<Note> get notesBox => Hive.box<Note>(notesBoxName);
  Box<Folder> get foldersBox => Hive.box<Folder>(foldersBoxName);

  // --- Note Operations ---

  Future<void> addNote({required String title, required String content, String? folderId}) async {
    final note = Note(
      id: _uuid.v4(), // Generate unique ID
      title: title.isNotEmpty ? title : 'Untitled Note',
      content: content,
      creationDate: DateTime.now(),
      folderId: folderId,
    );
    await notesBox.put(note.id, note);
  }

  // Marks a note as deleted (soft delete)
  Future<void> softDeleteNote(String noteId) async {
    final note = notesBox.get(noteId);
    if (note != null) {
      final updatedNote = note.copyWith(isDeleted: true, lastModified: DateTime.now());
      await notesBox.put(noteId, updatedNote);
      print("[HiveService softDeleteNote] Marked Note ID: $noteId as deleted."); // DEBUG
    } else {
      print("[HiveService softDeleteNote] Note ID: $noteId not found."); // DEBUG
    }
  }

  // Restores a note from the trash
  Future<void> restoreNote(String noteId) async {
    final note = notesBox.get(noteId);
    if (note != null && note.isDeleted) {
       final updatedNote = note.copyWith(isDeleted: false, lastModified: DateTime.now());
       await notesBox.put(noteId, updatedNote);
       print("[HiveService restoreNote] Restored Note ID: $noteId."); // DEBUG
    } else {
       print("[HiveService restoreNote] Note ID: $noteId not found or not deleted."); // DEBUG
    }
  }

  // Permanently deletes a note from the box
  Future<void> permanentlyDeleteNote(String noteId) async {
    await notesBox.delete(noteId);
    print("[HiveService permanentlyDeleteNote] Permanently deleted Note ID: $noteId."); // DEBUG
  }

  Future<void> updateNote(Note note) async {
    // No longer using note.save() as it requires the specific instance from the box.
    // Using box.put() works correctly with copied/updated instances.
    print("[HiveService updateNote] Saving Note ID: ${note.id}, Title: ${note.title}, Content: ${note.content.substring(0, min(note.content.length, 50))}..., FolderID: ${note.folderId}, Modified: ${note.lastModified}"); // DEBUG PRINT (Limited content length)
    await notesBox.put(note.id, note); // Use put() instead of save()
   }

  // // Original deleteNote - Keeping commented for reference, replaced by softDeleteNote
  // Future<void> deleteNote(String noteId) async {
  //   await notesBox.delete(noteId);
  // }

  List<Note> getAllNotes({bool includeDeleted = false}) {
     if (includeDeleted) {
       return notesBox.values.toList();
     } else {
       return notesBox.values.where((note) => !note.isDeleted).toList();
     }
    return notesBox.values.toList();
    // Consider sorting by date here if needed
    // notes.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    // return notes;
  }

  // --- Folder Operations ---

  Future<void> addFolder({required String name, required int colorValue}) async {
     final folder = Folder(
      id: _uuid.v4(),
      name: name.isNotEmpty ? name : 'New Folder',
      colorValue: colorValue,
    );
    await foldersBox.put(folder.id, folder);
  }

   Future<void> updateFolder(Folder folder) async {
    await folder.save();
  }

  Future<void> deleteFolder(String folderId) async {
    // Important: Decide how to handle notes within the deleted folder.
    // Option 1: Delete notes within the folder
    // Option 2: Remove folderId from notes (orphan them)
    // Option 3: Prevent deletion if folder is not empty

    // Example (Option 2): Orphan notes
    final notesInFolder = notesBox.values.where((note) => note.folderId == folderId).toList();
    for (var note in notesInFolder) {
      note.folderId = null;
      await note.save();
    }

    await foldersBox.delete(folderId);
  }

  List<Folder> getAllFolders() {
    return foldersBox.values.toList();
  }

  // --- Helper Methods ---

  ValueListenable<Box<Note>> listenToNotes() {
    return notesBox.listenable();
  }

   ValueListenable<Box<Folder>> listenToFolders() {
    return foldersBox.listenable();
  }


  // Close boxes if necessary (e.g., on app exit)
  Future<void> closeBoxes() async {
    await notesBox.close();
    await foldersBox.close();
  }
}
