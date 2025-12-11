import 'package:flutter/material.dart';
import 'notes_management_screen.dart';

class ContentUploadScreen extends StatelessWidget {
  final String contentType;

  const ContentUploadScreen({super.key, required this.contentType});

  @override
  Widget build(BuildContext context) {
    if (contentType == 'notes') {
      return const NotesManagementScreen();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload ${contentType.toUpperCase()}'),
      ),
      body: const Center(
        child: Text('Coming soon'),
      ),
    );
  }
}