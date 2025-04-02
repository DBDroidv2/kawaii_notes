import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kawaii_notes/src/models/note.dart';
import 'package:kawaii_notes/src/utils/theme.dart'; // For colors

class NoteCard extends StatelessWidget {
  final Note note;
  // Removed onTap - handled by GestureDetector in HomeScreen

  const NoteCard({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy - hh:mm a');
    final String formattedDate = formatter.format(note.creationDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      // Removed InkWell
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              note.title.isNotEmpty ? note.title : 'Untitled Note',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Content Preview
            Text(
              note.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: kawaiiText.withOpacity(0.8),
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Date
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: kawaiiText.withOpacity(0.6),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
