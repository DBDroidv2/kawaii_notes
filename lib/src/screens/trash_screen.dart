import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kawaii_notes/src/models/note.dart';
import 'package:kawaii_notes/src/services/hive_service.dart';
import 'package:kawaii_notes/src/services/service_locator.dart';
import 'package:kawaii_notes/src/widgets/kawaii_animated_background.dart';
import 'package:kawaii_notes/src/widgets/note_card.dart'; // Reuse NoteCard

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final HiveService _hiveService = locator<HiveService>();

  // Function to restore a note
  Future<void> _restoreNote(String noteId) async {
    await _hiveService.restoreNote(noteId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Note restored! Yay! (*^▽^*)'), backgroundColor: Theme.of(context).primaryColor),
      );
    }
  }

  // Confirmation and function to delete a note permanently
  Future<void> _confirmPermanentDelete(BuildContext context, Note note) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('Delete Permanently?'),
          content: Text('Are you sure you want to permanently delete "${note.title}"? This cannot be undone! (O_O)'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
            TextButton(style: TextButton.styleFrom(foregroundColor: Colors.redAccent), child: const Text('Delete Forever'), onPressed: () => Navigator.of(context).pop(true)),
          ],
        );
      },
    );

    if (confirm == true) {
      await _hiveService.permanentlyDeleteNote(note.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Note permanently deleted!'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

    // Confirmation and function to empty the trash
  Future<void> _confirmEmptyTrash(BuildContext context, List<Note> trashNotes) async {
    if (trashNotes.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trash is already empty!'), backgroundColor: Colors.grey),
        );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('Empty Trash?'),
          content: Text('Permanently delete all ${trashNotes.length} notes in the trash? This cannot be undone!'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
            TextButton(style: TextButton.styleFrom(foregroundColor: Colors.redAccent), child: const Text('Empty Trash'), onPressed: () => Navigator.of(context).pop(true)),
          ],
        );
      },
    );

    if (confirm == true) {
       int count = 0;
       for (var note in trashNotes) {
          await _hiveService.permanentlyDeleteNote(note.id);
          count++;
       }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Emptied trash ($count notes)!'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash 🗑️'),
        actions: [
           // Add Empty Trash button - conditional on builder result
        ],
      ),
      body: KawaiiStaticBackground(
        child: ValueListenableBuilder(
          valueListenable: _hiveService.listenToNotes(),
          builder: (context, Box<Note> box, Widget? childForAppBar) {
            final List<Note> trashNotes = box.values.where((note) => note.isDeleted).toList();
            // Sort by modification date (when they were deleted)
            trashNotes.sort((a, b) => b.lastModified.compareTo(a.lastModified));

             // Build AppBar action here, so we know if there are notes to empty
            final appBarActions = <Widget>[
               if (trashNotes.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_forever_outlined),
                  tooltip: 'Empty Trash',
                  onPressed: () => _confirmEmptyTrash(context, trashNotes),
                ),
            ];

            if (trashNotes.isEmpty) {
              return const Center(child: Text('Trash is empty! (⌒‿⌒)', style: TextStyle(fontSize: 18)));
            }

            // Update the AppBar directly (a bit hacky, better with state management)
            WidgetsBinding.instance.addPostFrameCallback((_) {
               if (mounted) {
                  // This rebuilds the parent Scaffold, updating AppBar actions
                  setState(() {});
               }
             });

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: trashNotes.length,
              itemBuilder: (context, index) {
                final note = trashNotes[index];
                return Card( // Use Card for explicit background/actions
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                   child: ListTile(
                     // Consider slightly different styling for deleted notes
                     leading: Icon(Icons.note_outlined, color: Colors.grey.shade600),
                     title: Text(note.title.isNotEmpty ? note.title : 'Untitled Note', maxLines: 1, overflow: TextOverflow.ellipsis),
                     subtitle: Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                     trailing: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         IconButton(
                           icon: const Icon(Icons.restore_from_trash_outlined),
                           color: Colors.green.shade600,
                           tooltip: 'Restore Note',
                           onPressed: () => _restoreNote(note.id),
                         ),
                         IconButton(
                           icon: const Icon(Icons.delete_forever_outlined),
                            color: Colors.redAccent.shade400,
                           tooltip: 'Delete Permanently',
                           onPressed: () => _confirmPermanentDelete(context, note),
                         ),
                       ],
                     ),
                   ),
                 );
              },
            );
          },
          // Pass actions to builder to rebuild AppBar correctly
          // child: childForAppBar, // Not needed with the postFrameCallback hack
        ),
      ),
    );
  }
}

// Helper widget for AppBar actions update (Alternative approach)
// class _TrashAppBarActions extends StatelessWidget {
//   final VoidCallback onEmptyTrash;
//   final bool canEmpty;

//   const _TrashAppBarActions({required this.onEmptyTrash, required this.canEmpty});

//   @override
//   Widget build(BuildContext context) {
//     if (!canEmpty) return const SizedBox.shrink(); // Return empty if trash is empty

//     return IconButton(
//       icon: const Icon(Icons.delete_forever_outlined),
//       tooltip: 'Empty Trash',
//       onPressed: onEmptyTrash,
//     );
//   }
// }
