import 'dart:math'; // For generating a random initial color
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kawaii_notes/src/models/folder.dart';
import 'package:kawaii_notes/src/services/hive_service.dart';
import 'package:kawaii_notes/src/services/service_locator.dart';
import 'package:kawaii_notes/src/utils/theme.dart'; // For colors
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Import color picker
import 'package:kawaii_notes/src/widgets/kawaii_animated_background.dart'; // Import background

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final HiveService _hiveService = locator<HiveService>();

  // --- Add Folder Dialog ---
  void _showAddFolderDialog() {
    final nameController = TextEditingController();
    // Start with a random pastel-ish color
    Color selectedColor = HSLColor.fromAHSL(
            1.0, Random().nextDouble() * 360, 0.7, 0.85) // Slightly adjusted saturation/lightness
        .toColor();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to update color preview inside the dialog
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            title: const Text('New Kawaii Folder'),
            content: SingleChildScrollView( // Prevent overflow if keyboard appears
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Folder Name'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  const Text('Choose a cute color:'),
                  const SizedBox(height: 10),
                  // Simple Block Color Picker
                  BlockPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                       setStateDialog(() => selectedColor = color); // Update color preview
                    },
                    availableColors: const [ // Predefined kawaii pastel options
                      kawaiiPink, kawaiiLightPink, kawaiiBlue, kawaiiLightBlue,
                      kawaiiYellow, kawaiiGreen, kawaiiPurple, Colors.grey,
                      Color(0xFFFFDAB9), // PeachPuff
                      Color(0xFFE0FFFF), // LightCyan
                      Color(0xFFFFF0F5), // LavenderBlush
                      Color(0xFFFAFAD2), // LightGoldenrodYellow
                    ],
                    layoutBuilder: pickerLayoutBuilder, // Use helper for layout
                    itemBuilder: pickerItemBuilder, // Use helper for item appearance
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                 style: TextButton.styleFrom(foregroundColor: Theme.of(context).primaryColor), // Use theme color
                child: const Text('Add Folder'),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    _hiveService.addFolder(
                      name: nameController.text,
                      colorValue: selectedColor.value, // Save color int value
                    );
                    Navigator.of(context).pop();
                  } else {
                    // Optional: Show validation error
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Please enter a folder name! >.<'), backgroundColor: Colors.orangeAccent,)
                     );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  // --- Edit Folder Dialog ---
   void _showEditFolderDialog(Folder folder) {
    final nameController = TextEditingController(text: folder.name);
    Color selectedColor = Color(folder.colorValue); // Start with existing color

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            title: Text('Edit ${folder.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Folder Name'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  const Text('Change color:'),
                  const SizedBox(height: 10),
                  BlockPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      setStateDialog(() => selectedColor = color);
                    },
                     availableColors: const [ // Same colors as add dialog
                      kawaiiPink, kawaiiLightPink, kawaiiBlue, kawaiiLightBlue,
                      kawaiiYellow, kawaiiGreen, kawaiiPurple, Colors.grey,
                      Color(0xFFFFDAB9), Color(0xFFE0FFFF),
                      Color(0xFFFFF0F5), Color(0xFFFAFAD2),
                    ],
                    layoutBuilder: pickerLayoutBuilder,
                    itemBuilder: pickerItemBuilder,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
                child: const Text('Save Changes'),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    final updatedFolder = folder.copyWith(
                      name: nameController.text,
                      colorValue: selectedColor.value,
                    );
                    _hiveService.updateFolder(updatedFolder);
                    Navigator.of(context).pop();
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Folder name cannot be empty! >.<'), backgroundColor: Colors.orangeAccent,)
                     );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  // --- Delete Folder Confirmation ---
  Future<void> _confirmDeleteFolder(Folder folder) async {
     final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text('Delete "${folder.name}"?'),
          content: const Text('Are you sure you want to delete this folder? Notes inside will NOT be deleted but will lose their folder assignment.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Delete Folder'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

     if (confirm == true) {
      await _hiveService.deleteFolder(folder.id);
      // Optional: Show snackbar confirmation
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Folder "${folder.name}" deleted! (´• ω •`)'),
            backgroundColor: Theme.of(context).hintColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // --- Color Picker Layout ---
  Widget pickerLayoutBuilder(BuildContext context, List<Color> colors, PickerItem child) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return SizedBox(
      width: 300,
      height: orientation == Orientation.portrait ? 360 : 240,
      child: GridView.count(
        crossAxisCount: orientation == Orientation.portrait ? 4 : 6,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        children: colors.map((Color color) => child(color)).toList(),
      ),
    );
  }

  // --- Color Picker Item ---
  Widget pickerItemBuilder(Color color, bool isCurrentColor, void Function() changeColor) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Cute rounded squares
        color: color,
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.8),
              offset: const Offset(1, 2),
              blurRadius: 3)
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: changeColor,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 210),
            opacity: isCurrentColor ? 1 : 0,
            child: Icon(Icons.done, // Checkmark for selected color
                color: useWhiteForeground(color) ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders 📂 kawaii'), // Added emoji
      ),
      body: KawaiiStaticBackground( // Wrap body with background
        child: ValueListenableBuilder(
          valueListenable: _hiveService.listenToFolders(),
          builder: (context, Box<Folder> box, _) {
            final folders = box.values.toList().cast<Folder>();

          if (folders.isEmpty) {
            return Center(
              child: Text(
                'No folders yet! Tap + to create one. (* ^ ω ^)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
                ),
            );
          }

          return ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              // Simple folder representation for now
              return ListTile(
                leading: Icon(Icons.folder_rounded, color: Color(folder.colorValue).withOpacity(0.8), size: 30), // Make icon more visible
                title: Text(folder.name, style: Theme.of(context).textTheme.titleMedium),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Edit Folder',
                      onPressed: () => _showEditFolderDialog(folder),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      tooltip: 'Delete Folder',
                      onPressed: () => _confirmDeleteFolder(folder),
                    ),
                  ],
                ),
                 onTap: () {
                  // TODO: Navigate to view notes within this folder?
                  // Or maybe just close this screen and filter HomeScreen?
                  Navigator.pop(context, folder.id); // Example: Pop back returning folder ID
                },
              );
            },
            );
          },
        ),
      ), // End KawaiiStaticBackground
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFolderDialog,
        tooltip: 'Add Folder',
        child: const Icon(Icons.create_new_folder_outlined),
      ),
    );
  }
}
