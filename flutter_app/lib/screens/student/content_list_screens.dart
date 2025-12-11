import 'package:flutter/material.dart';

// Placeholder screens for other content types
class BooksListScreen extends StatelessWidget {
  const BooksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Books')),
      body: const Center(child: Text('Books List - Implementation similar to Notes')),
    );
  }
}

class TestsListScreen extends StatelessWidget {
  const TestsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tests')),
      body: const Center(child: Text('Tests List - Implementation similar to Notes')),
    );
  }
}

class PPTsListScreen extends StatelessWidget {
  const PPTsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presentations')),
      body: const Center(child: Text('PPTs List - Implementation similar to Notes')),
    );
  }
}

class ProjectsListScreen extends StatelessWidget {
  const ProjectsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: const Center(child: Text('Projects List - Implementation similar to Notes')),
    );
  }
}

class AssignmentsListScreen extends StatelessWidget {
  const AssignmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: const Center(child: Text('Assignments List - Implementation similar to Notes')),
    );
  }
}
