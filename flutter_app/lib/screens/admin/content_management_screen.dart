import 'package:flutter/material.dart';
import 'notes_management_screen.dart';
import 'books_management_screen.dart';
import 'ppts_management_screen.dart';
import 'projects_management_screen.dart';
import 'assignments_management_screen.dart';
import 'content_upload_screen.dart';

class ContentManagementScreen extends StatelessWidget {
  const ContentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _ContentCard(
              title: 'Notes',
              icon: Icons.note_outlined,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotesManagementScreen(),
                  ),
                );
              },
            ),
            _ContentCard(
              title: 'Books',
              icon: Icons.menu_book_outlined,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BooksManagementScreen(),
                  ),
                );
              },
            ),
            _ContentCard(
              title: 'Tests',
              icon: Icons.quiz_outlined,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContentUploadScreen(contentType: 'tests'),
                  ),
                );
              },
            ),
            _ContentCard(
              title: 'PPTs',
              icon: Icons.slideshow_outlined,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PPTsManagementScreen(),
                  ),
                );
              },
            ),
            _ContentCard(
              title: 'Projects',
              icon: Icons.work_outline,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProjectsManagementScreen(),
                  ),
                );
              },
            ),
            _ContentCard(
              title: 'Assignments',
              icon: Icons.assignment_outlined,
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssignmentsManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ContentCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}