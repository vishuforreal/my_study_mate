import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/category_service.dart';
import '../../services/subject_service.dart';
import '../../services/admin_service.dart';
import '../../models/category_model.dart';
import '../../models/subject_model.dart';

class BooksManagementScreen extends StatefulWidget {
  const BooksManagementScreen({super.key});

  @override
  State<BooksManagementScreen> createState() => _BooksManagementScreenState();
}

class _BooksManagementScreenState extends State<BooksManagementScreen> {
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
      appBar: AppBar(title: const Text('Books Management')),
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
                                  label: const Text('Upload Book'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showBooksListDialog(),
                                  icon: const Icon(Icons.list),
                                  label: const Text('View Books'),
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
    final authorController = TextEditingController();
    final unitController = TextEditingController(text: '1');
    String pdfLink = '';
    String coverImage = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Book'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Book Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Author'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit Number'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Google Drive PDF Link'),
                onChanged: (value) => pdfLink = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Cover Image URL (Optional)'),
                onChanged: (value) => coverImage = value,
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
                  final bookData = {
                    'title': titleController.text.trim(),
                    'author': authorController.text.trim().isEmpty ? 'Unknown' : authorController.text.trim(),
                    'subject': _selectedSubject!.name,
                    'unit': int.parse(unitController.text),
                    'category': _selectedCategory!.id,
                    'subcategory': _selectedSubcategory!,
                    'pdfLink': pdfLink.trim(),
                    'coverImage': coverImage.trim(),
                  };
                  
                  await _adminService.uploadBook(bookData);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Book uploaded successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in title and unit number')),
                );
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _showBooksListDialog() async {
    try {
      final units = await _subjectService.getBooksForSubject(_selectedSubject!.name);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${_selectedSubject!.name} - Books'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: units.isEmpty
                ? const Center(child: Text('No books found'))
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
        SnackBar(content: Text('Error loading books: $e')),
      );
    }
  }

  void _viewPDF(String pdfUrl) async {
    try {
      final Uri url = Uri.parse(pdfUrl);
      await launchUrl(url, mode: LaunchMode.inAppWebView);
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
        await _adminService.deleteBookUnit(_selectedSubject!.name, unitNumber);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unit $unitNumber deleted successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting unit: $e')),
        );
      }
    }
  }
}