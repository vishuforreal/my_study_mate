import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
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
                        Column(
                          children: [
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Search subjects',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (query) {
                                setState(() {
                                  if (query.isEmpty) {
                                    // Show all subjects
                                  } else {
                                    // Filter subjects by name
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 16),
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
                                if (_selectedSubject != null)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteSubject(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_selectedSubject != null)
                              ElevatedButton(
                                onPressed: () => _showManageSubjectDialog(),
                                child: const Text('Manage Subject'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Upload Button and Notes List
                        if (_selectedSubject != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showUploadDialog(),
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Upload Note'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showNotesListDialog(),
                                  icon: const Icon(Icons.list),
                                  label: const Text('View Notes'),
                                ),
                              ),
                            ],
                          ),
                        ],
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
    final unitController = TextEditingController(text: '1');
    String pdfLink = '';
    String coverImageUrl = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Upload Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Unit Name/Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Unit Number'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(),
                  decoration: const InputDecoration(labelText: 'Google Drive PDF Link'),
                  onChanged: (value) => pdfLink = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(),
                  decoration: const InputDecoration(labelText: 'Cover Image URL (Optional)'),
                  onChanged: (value) => coverImageUrl = value,
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
                if (titleController.text.isNotEmpty && unitController.text.isNotEmpty) {
                  try {
                    // Create mock note data
                    final noteData = {
                      'title': titleController.text,
                      'subject': _selectedSubject!.name,
                      'unit': int.parse(unitController.text),
                      'category': _selectedCategory!.id,
                      'subcategory': _selectedSubcategory!,
                      'pdfLink': pdfLink,
                      'coverImageUrl': coverImageUrl,
                    };
                    
                    // Call the upload API
                    await _adminService.uploadNote(noteData);
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note uploaded successfully')),
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

  void _deleteSubject() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${_selectedSubject!.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _subjectService.deleteSubject(_selectedSubject!.id);
                Navigator.pop(context);
                setState(() {
                  _selectedSubject = null;
                  _subjects.removeWhere((s) => s.id == _selectedSubject!.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subject deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showManageSubjectDialog() {
    final controller = TextEditingController(text: _selectedSubject!.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Subject'),
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
                  await _subjectService.updateSubject(_selectedSubject!.id, controller.text.trim());
                  Navigator.pop(context);
                  _loadSubjects();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subject updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showNotesListDialog() async {
    try {
      final units = await _subjectService.getUnitsForSubject(_selectedSubject!.name);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${_selectedSubject!.name} - Notes'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: units.isEmpty
                ? const Center(child: Text('No notes found'))
                : ListView.builder(
                    itemCount: units.length,
                    itemBuilder: (context, index) {
                      final unit = units[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${unit['unit']}'),
                          ),
                          title: Text(unit['title']),
                          subtitle: Text('Unit ${unit['unit']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _viewPDF(unit['pdfUrl']),
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                tooltip: 'View PDF',
                              ),
                              IconButton(
                                onPressed: () => _deleteUnit(unit['unit']),
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete Unit',
                              ),
                            ],
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
        SnackBar(content: Text('Error loading notes: $e')),
      );
    }
  }

  void _viewPDF(String pdfUrl) async {
    try {
      final Uri url = Uri.parse(pdfUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PDF')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: $e')),
      );
    }
  }

  Future<void> _deleteUnit(int unitNumber) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Unit'),
        content: Text('Are you sure you want to delete Unit $unitNumber?'),
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
        await _adminService.deleteUnit(_selectedSubject!.name, unitNumber);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unit $unitNumber deleted successfully')),
        );
        Navigator.pop(context); // Close notes dialog
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting unit: $e')),
        );
      }
    }
  }
}