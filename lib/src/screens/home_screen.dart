import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kawaii_notes/src/models/note.dart';
import 'package:kawaii_notes/src/screens/note_edit_screen.dart';
import 'package:kawaii_notes/src/services/hive_service.dart';
import 'package:kawaii_notes/src/services/service_locator.dart';
import 'package:kawaii_notes/src/widgets/note_card.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kawaii_notes/src/screens/folder_screen.dart'; // Import FolderScreen
import 'package:kawaii_notes/src/screens/trash_screen.dart'; // Import TrashScreen
import 'package:kawaii_notes/src/widgets/kawaii_animated_background.dart'; // Import background

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Add SingleTickerProviderStateMixin for animations
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final HiveService _hiveService = locator<HiveService>();
  String? _selectedFolderId;
  String _currentAppBarTitle = 'Kawaii Notes ✨';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Animation Controller for FAB bounce
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  // State for NoteCard tap animation
  String? _animatingNoteId; // ID of the note currently being animated

  @override
  void initState() {
    super.initState();
    _updateAppBarTitle();

    // Initialize FAB Animation Controller
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300), // Duration of bounce
      vsync: this, // Assign vsync
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate( // Adjusted end scale
       CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut)
    );

     _searchController.addListener(() {
      if (_searchQuery != _searchController.text) {
         setState(() {
           _searchQuery = _searchController.text;
         });
      }
     });
  }

   // Helper to update AppBar title based on filter
  void _updateAppBarTitle() {
    if (_selectedFolderId == null) {
      _currentAppBarTitle = 'Kawaii Notes ✨';
    } else {
      try {
         if (_hiveService.foldersBox.isOpen) {
            final folder = _hiveService.foldersBox.get(_selectedFolderId!);
            _currentAppBarTitle = folder?.name ?? 'Selected Folder';
         } else {
             _currentAppBarTitle = 'Selected Folder';
         }
      } catch (e) {
         print("Error getting folder for title: $e");
        _currentAppBarTitle = 'Selected Folder';
      }
    }
  }

  @override
  void dispose() {
     _searchController.dispose();
     _fabAnimationController.dispose(); // Dispose animation controller
    super.dispose();
  }

  // Trigger FAB bounce animation
  void _triggerFabBounce() {
     _fabAnimationController.forward().then((_) {
       // Optional delay before reversing for a slightly longer "squish"
       Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) { // Check if still mounted before reversing
             _fabAnimationController.reverse();
          }
       });
     });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField( // Search field in AppBar
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              )
            : Text(_currentAppBarTitle), // Normal title
        actions: [
           // Toggle Search/Close Icon
           IconButton(
             icon: Icon(_isSearching ? Icons.close : Icons.search),
             onPressed: () {
               setState(() {
                 if (_isSearching) {
                   _isSearching = false;
                   _searchQuery = '';
                   _searchController.clear();
                   FocusScope.of(context).unfocus();
                 } else {
                   _isSearching = true;
                 }
               });
             },
             tooltip: _isSearching ? 'Close Search' : 'Search Notes',
           ),
           // Folder actions only if not searching
           if (!_isSearching) ...[
             IconButton(
               icon: const Icon(Icons.folder_copy_outlined),
               onPressed: () async {
                 final result = await Navigator.of(context).push<String?>(
                   MaterialPageRoute(builder: (context) => const FolderScreen()),
                 );
                 if (mounted) {
                   setState(() { _selectedFolderId = result; _updateAppBarTitle(); });
                 }
               },
               tooltip: 'Manage Folders',
             ),
             if (_selectedFolderId != null)
               IconButton(
                 icon: const Icon(Icons.clear_all_rounded),
                 onPressed: () {
                   setState(() { _selectedFolderId = null; _updateAppBarTitle(); });
                 },
                  tooltip: 'Show All Notes',
                ),
             // Add Trash Bin Button
             IconButton(
               icon: const Icon(Icons.delete_sweep_outlined), // Icon for trash
               onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const TrashScreen()), // Navigate to TrashScreen (will create next)
                  );
               },
               tooltip: 'View Trash',
             ),
            ],
         ],
      ),
      body: KawaiiStaticBackground(
        child: ValueListenableBuilder(
          valueListenable: _hiveService.listenToNotes(),
          builder: (context, Box<Note> box, _) {
            // Filter notes based on deleted status, folder AND search query
            final List<Note> notes = box.values.where((note) {
              // Skip deleted notes
              if (note.isDeleted) return false;

              final folderMatch = _selectedFolderId == null || note.folderId == _selectedFolderId;
              if (!folderMatch) return false;
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                final titleMatch = note.title.toLowerCase().contains(query);
                final contentMatch = note.content.toLowerCase().contains(query);
                return titleMatch || contentMatch;
              }
              return true;
            }).toList();

            notes.sort((a, b) => b.creationDate.compareTo(a.creationDate));

            if (notes.isEmpty) {
              String emptyMessage = 'No notes yet! Tap + to add one. (｡◕‿◕｡)';
              if (_searchQuery.isNotEmpty) emptyMessage = 'No notes found matching "$_searchQuery"';
              if (_selectedFolderId != null) emptyMessage += ' in this folder.';
              return Center(child: Text(emptyMessage, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18), textAlign: TextAlign.center));
            }

            // Display the filtered list
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Slidable(
                  key: ValueKey(note.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    // dismissible: DismissiblePane(onDismissed: () => _confirmMoveToTrash(context, note.id)), // Can still use dismissible if preferred
                    children: [
                      SlidableAction(
                        onPressed: (context) => _confirmMoveToTrash(context, note.id), // Changed function call
                        backgroundColor: Colors.orangeAccent, // Changed color for visual distinction
                        foregroundColor: Colors.white,
                        icon: Icons.delete_sweep_outlined, // Changed icon
                        label: 'Trash', // Changed label
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ],
                  ),
                  // Wrap NoteCard with GestureDetector and AnimatedScale for tap animation
                   child: GestureDetector(
                      onTapDown: (_) => setState(() => _animatingNoteId = note.id),
                      onTapUp: (_) {
                        print("[HomeScreen onTapUp] Navigating to edit note: ${note.id}"); // DEBUG PRINT
                         setState(() => _animatingNoteId = null);
                         Navigator.of(context).push(MaterialPageRoute(builder: (context) => NoteEditScreen(note: note)));
                      },
                     onTapCancel: () => setState(() => _animatingNoteId = null),
                     child: AnimatedScale(
                        scale: _animatingNoteId == note.id ? 0.95 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        child: NoteCard(note: note), // Pass note only
                     ),
                  ),
                );
              },
            );
          },
        ),
      ), // End KawaiiStaticBackground
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           _triggerFabBounce(); // Trigger bounce
           // Navigate after a short delay
           Future.delayed(const Duration(milliseconds: 50), () {
              if(mounted) { // Check if still mounted
                 Navigator.of(context).push(MaterialPageRoute(builder: (context) => NoteEditScreen(note: null)));
              }
           });
        },
        tooltip: 'Add Note',
        child: ScaleTransition( // Apply scale animation to FAB icon
           scale: _fabScaleAnimation,
           child: const Icon(Icons.add),
        ),
      ),
    );
  } // End build method


  // Confirmation Dialog for Moving to Trash
  Future<void> _confirmMoveToTrash(BuildContext context, String noteId) async { // Renamed function
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('Move to Trash?'), // Changed title
          content: const Text('Move this cute note to the trash? You can restore it later.'), // Changed content
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
            TextButton(style: TextButton.styleFrom(foregroundColor: Colors.orangeAccent), child: const Text('Move to Trash'), onPressed: () => Navigator.of(context).pop(true)), // Changed button text & style
          ],
        );
      },
    );

    if (confirm == true) {
      await _hiveService.softDeleteNote(noteId); // Call softDeleteNote
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Note moved to trash! ( ´ ▽ ` )ﾉ'), backgroundColor: Theme.of(context).hintColor, duration: const Duration(seconds: 2))); // Updated message
      }
    }
  }

} // End _HomeScreenState
