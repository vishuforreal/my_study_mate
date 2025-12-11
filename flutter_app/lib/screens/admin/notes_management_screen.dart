import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/category_service.dart';
import '../../services/subject_service.dart';
import '../../services/admin_service.dart';
import '../../models/category_model.dart';
import '../../models/subject_model.dart';
import 'dart:io';

class NotesManagementScreen extends StatefulWidget {
  const NotesManagementScreen({super.key});

  @override
  State<NotesManagementScreen> createState() => _NotesManagementScreenState();
}

class _NotesManagementScreenState extends State<NotesManagementScreen> {
  final CategoryService _categoryService = CategoryService();
  final SubjectService _subjectService = SubjectService();
  final AdminService _adminService = AdminService();

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  String? _selectedSubcategory;
  List<SubjectModel> _subjects = [];
  SubjectModel? _selectedSubject;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _loadSubjects() async {
    if (_selectedCategory == null || _selectedSubcategory == null) return;

    try {
      final subjects = await _subjectService.getSubjects(
        category: _selectedCategory!.id,
        subcategory: _selectedSubcategory!,
      );
      setState(() => _subjects = subjects);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text('No categories available'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Category Selection
                      DropdownButtonFormField<CategoryModel>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (category) {
                          setState(() {
                            _selectedCategory = category;
                            _selectedSubcategory = null;
                            _subjects.clear();
                            _selectedSubject = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Subcategory Selection
                      if (_selectedCategory != null)
                        DropdownButtonFormField<String>(
                          value: _selectedSubcategory,
                          decoration: const InputDecoration(labelText: 'Subcategory'),
                          items: _selectedCategory!.subcategories.map((sub) {
                            return DropdownMenuItem(
                              value: sub.name,
                              child: Text(sub.name),
                            );
                          }).toList(),
                          onChanged: (subcategory) {
                            setState(() {
                              _selectedSubcategory = subcategory;
                              _subjects.clear();
                              _selectedSubject = null;
                            });
                            _loadSubjects();
                          },
                        ),
                      const SizedBox(height: 16),

                      // Subject Selection
                      if (_selectedSubcategory != null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<SubjectModel>(
                                value: _selectedSubject,
                                decoration: const InputDecoration(labelText: 'Subject'),
                                items: _subjects.map((subject) {
                                  return DropdownMenuItem(
                                    value: subject,
                                    child: Text(subject.name),
                                  );
                                }).toList(),
                                onChanged: (subject) {
                                  setState(() => _selectedSubject = subject);
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _showCreateSubjectDialog(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Upload Button
                        if (_selectedSubject != null)
                          ElevatedButton.icon(
                            onPressed: () => _showUploadDialog(),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Note'),
                          ),
                      ],
                    ],
                  ),
                ),
    );
  }

  void _showCreateSubjectDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Subject'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Subject Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  await _subjectService.createSubject(
                    controller.text.trim(),
                    _selectedCategory!.id,
                    _selectedSubcategory!,
                  );
                  Navigator.pop(context);
                  _loadSubjects();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    final titleController = TextEditingController();
    File? coverImage;
    int unit = 1; // Auto-increment unit

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Upload Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              Text('Unit: $unit'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setDialogState(() {
                      coverImage = File(image.path);
                    });
                  }
                },
                child: Text(coverImage == null ? 'Select Cover Image' : 'Image Selected'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && coverImage != null) {
                  // Simulate upload
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note uploaded successfully')),
                  );
                }
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}