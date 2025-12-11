import 'package:flutter/material.dart';
import '../../models/subject_model.dart';

class UnitsListScreen extends StatelessWidget {
  final SubjectModel subject;

  const UnitsListScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    // Mock units data - in real app, fetch from API
    final units = List.generate(5, (index) => 'Unit ${index + 1}');

    return Scaffold(
      appBar: AppBar(title: Text('${subject.name} - Units')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: units.length,
        itemBuilder: (context, index) {
          final unit = units[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(unit),
              subtitle: const Text('PDF Available'),
              trailing: const Icon(Icons.picture_as_pdf, color: Colors.red),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening $unit PDF')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}