import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class ProjectsManagementScreen extends StatefulWidget {
  const ProjectsManagementScreen({super.key});

  @override
  State<ProjectsManagementScreen> createState() => _ProjectsManagementScreenState();
}

class _ProjectsManagementScreenState extends State<ProjectsManagementScreen> {
  final AdminService _adminService = AdminService();

  String? _selectedCategory;
  final List<String> _categories = [
    'Web Development',
    'Mobile App',
    'Desktop App',
    'Data Science',
    'Machine Learning',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Project Category'),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
            const SizedBox(height: 24),

            if (_selectedCategory != null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showUploadDialog(),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Project'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showProjectsListDialog(),
                      icon: const Icon(Icons.list),
                      label: const Text('View Projects'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showUploadDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final technologyController = TextEditingController();
    final tagsController = TextEditingController();
    String fileUrl = '';
    String thumbnailUrl = '';
    String difficulty = 'Intermediate';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Upload Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Project Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: technologyController,
                  decoration: const InputDecoration(labelText: 'Technology'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: difficulty,
                  decoration: const InputDecoration(labelText: 'Difficulty'),
                  items: ['Beginner', 'Intermediate', 'Advanced'].map((diff) {
                    return DropdownMenuItem(value: diff, child: Text(diff));
                  }).toList(),
                  onChanged: (value) => setDialogState(() => difficulty = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'react, javascript, frontend',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Project File URL'),
                  onChanged: (value) => fileUrl = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Thumbnail URL (Optional)'),
                  onChanged: (value) => thumbnailUrl = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && 
                    descriptionController.text.isNotEmpty &&
                    technologyController.text.isNotEmpty) {
                  try {
                    final projectData = {
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'technology': technologyController.text,
                      'category': _selectedCategory!,
                      'difficulty': difficulty,
                      'tags': tagsController.text.split(',').map((e) => e.trim()).toList(),
                      'fileUrl': fileUrl,
                      'thumbnailUrl': thumbnailUrl,
                    };
                    
                    await _adminService.uploadProject(projectData);
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Project uploaded successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectsListDialog() async {
    try {
      final projects = await _adminService.getProjectsByCategory(_selectedCategory!);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('$_selectedCategory - Projects'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: projects.isEmpty
                ? const Center(child: Text('No projects found'))
                : ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(project['difficulty'][0]),
                          ),
                          title: Text(project['title']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tech: ${project['technology']}'),
                              Text('Difficulty: ${project['difficulty']}'),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () => _deleteProject(project['_id']),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Project',
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading projects: $e')),
      );
    }
  }

  Future<void> _deleteProject(String projectId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _adminService.deleteProject(projectId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project deleted successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting project: $e')),
        );
      }
    }
  }
}