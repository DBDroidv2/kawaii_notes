import 'package:flutter/material.dart';
import 'package:kawaii_notes/src/models/folder.dart'; // Import Folder model
import 'package:kawaii_notes/src/models/note.dart';
import 'package:kawaii_notes/src/services/hive_service.dart';
import 'package:kawaii_notes/src/services/service_locator.dart';
import 'package:kawaii_notes/src/widgets/kawaii_animated_background.dart'; // Import background

class NoteEditScreen extends StatefulWidget {
  final Note? note; // Pass the note to edit, or null for a new note

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final HiveService _hiveService = locator<HiveService>();
  List<Folder> _folders = [];
  String? _selectedFolderId; // Use null for "No Folder"

  @override
  void initState() {
    super.initState();
    print("[NoteEditScreen initState] Editing note: ${widget.note?.id}, Title: ${widget.note?.title}"); // DEBUG PRINT
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedFolderId = widget.note?.folderId;
    _loadFolders();
  }

  // Load available folders
  Future<void> _loadFolders() async {
    // Use try-catch in case box isn't open, though it should be from main.dart
    try {
      final folders = _hiveService.getAllFolders();
      // Sort folders alphabetically for the dropdown
      folders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      setState(() {
        _folders = folders;
        // Ensure the initial selected ID is valid among loaded folders
        if (_selectedFolderId != null && !_folders.any((f) => f.id == _selectedFolderId)) {
          _selectedFolderId = null; // Reset if folder was deleted
        }
      });
    } catch (e) {
       print("Error loading folders: $e");
       // Handle error, maybe show a snackbar
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Save Note (including Folder ID)
  Future<void> _saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    // Basic validation
    if (title.isEmpty && content.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Cannot save an empty note! >.<'), backgroundColor: Colors.orangeAccent,)
       );
      return;
    }


    if (widget.note == null) {
      // Create new note
      await _hiveService.addNote(
        title: title,
        content: content,
        folderId: _selectedFolderId, // Pass selected folder ID
      );
    } else {
      // Update existing note
      final updatedNote = widget.note!.copyWith(
        title: title,
        content: content,
        folderId: _selectedFolderId,
        setFolderIdToNull: _selectedFolderId == null, // Explicitly handle nulling
        lastModified: DateTime.now(), // Update last modified time
      );
      print("[NoteEditScreen _saveNote] Calling updateNote with: ${updatedNote.id}, Title: ${updatedNote.title}, Folder: ${updatedNote.folderId}, Modified: ${updatedNote.lastModified}"); // DEBUG PRINT
      await _hiveService.updateNote(updatedNote);
    }

    if (mounted) {
       Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Kawaii Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save), // Changed Icon
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: KawaiiStaticBackground( // Wrap body with background
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Title Field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter a cute title!',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              // Folder Selection Dropdown
              if (_folders.isNotEmpty) // Only show dropdown if folders exist
                DropdownButtonFormField<String?>(
                  value: _selectedFolderId,
                  // Add decoration to match theme
                  decoration: InputDecoration(
                     labelText: 'Folder',
                     filled: true,
                     fillColor: Colors.white.withOpacity(0.7),
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12.0),
                       borderSide: BorderSide.none,
                     ),
                     contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  ),
                  hint: const Text('Select Folder (Optional)'),
                  isExpanded: true, // Make dropdown take full width
                  // Map folders to DropdownMenuItem, adding a "No Folder" option
                  items: [
                     const DropdownMenuItem<String?>(
                      value: null, // Represent "No Folder"
                      child: Text('No Folder'),
                    ),
                    ..._folders.map((Folder folder) {
                      return DropdownMenuItem<String?>(
                        value: folder.id,
                        child: Row( // Add color indicator
                          children: [
                             Icon(Icons.folder_rounded, size: 18, color: Color(folder.colorValue).withOpacity(0.8)),
                             const SizedBox(width: 8),
                             Text(folder.name),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFolderId = newValue;
                    });
                  },
                ),
              const SizedBox(height: 12),

              // Content Field
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Write your note here...',
                    alignLabelWithHint: true, // Align label to top
                  ),
                  maxLines: null, // Allow unlimited lines
                  expands: true, // Expand to fill available space
                  textAlignVertical: TextAlignVertical.top,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ), // End KawaiiStaticBackground
    );
  }
}
