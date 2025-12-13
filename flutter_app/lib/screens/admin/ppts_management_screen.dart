import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../services/subject_service.dart';
import '../../services/admin_service.dart';
import '../../models/category_model.dart';
import '../../models/subject_model.dart';

class PPTsManagementScreen extends StatefulWidget {
  const PPTsManagementScreen({super.key});

  @override
  State<PPTsManagementScreen> createState() => _PPTsManagementScreenState();
}

class _PPTsManagementScreenState extends State<PPTsManagementScreen> {
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
      appBar: AppBar(title: const Text('PPTs Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text('No categories available'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (_selectedSubject != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showUploadDialog(),
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Upload PPT'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showPPTsListDialog(),
                                  icon: const Icon(Icons.list),
                                  label: const Text('View PPTs'),
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

  void _showUploadDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String fileUrl = '';
    String thumbnailUrl = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload PPT'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'PPT Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'PPT File URL'),
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
              if (titleController.text.isNotEmpty) {
                try {
                  final pptData = {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'subject': _selectedSubject!.name,
                    'category': _selectedCategory!.name,
                    'course': _selectedSubcategory!,
                    'fileUrl': fileUrl,
                    'thumbnailUrl': thumbnailUrl,
                  };
                  
                  await _adminService.uploadPPT(pptData);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PPT uploaded successfully')),
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
    );
  }

  void _showPPTsListDialog() async {
    try {
      final ppts = await _subjectService.getPPTsForSubject(_selectedSubject!.name);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${_selectedSubject!.name} - PPTs'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ppts.isEmpty
                ? const Center(child: Text('No PPTs found'))
                : ListView.builder(
                    itemCount: ppts.length,
                    itemBuilder: (context, index) {
                      final ppt = ppts[index];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.slideshow),
                          ),
                          title: Text(ppt['title']),
                          subtitle: Text(ppt['description'] ?? ''),
                          trailing: IconButton(
                            onPressed: () => _deletePPT(ppt['_id']),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete PPT',
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
        SnackBar(content: Text('Error loading PPTs: $e')),
      );
    }
  }

  Future<void> _deletePPT(String pptId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete PPT'),
        content: const Text('Are you sure you want to delete this PPT?'),
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
        await _adminService.deletePPT(pptId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PPT deleted successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting PPT: $e')),
        );
      }
    }
  }
}