import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../services/subject_service.dart';
import '../../services/admin_service.dart';
import '../../models/category_model.dart';
import '../../models/subject_model.dart';

class AssignmentsManagementScreen extends StatefulWidget {
  const AssignmentsManagementScreen({super.key});

  @override
  State<AssignmentsManagementScreen> createState() => _AssignmentsManagementScreenState();
}

class _AssignmentsManagementScreenState extends State<AssignmentsManagementScreen> {
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
      appBar: AppBar(title: const Text('Assignments Management')),
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
                                  label: const Text('Create Assignment'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAssignmentsListDialog(),
                                  icon: const Icon(Icons.list),
                                  label: const Text('View Assignments'),
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
    final totalMarksController = TextEditingController(text: '100');
    String assignmentFileUrl = '';
    String solutionFileUrl = '';
    DateTime? deadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Assignment Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: totalMarksController,
                  decoration: const InputDecoration(labelText: 'Total Marks'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(deadline == null 
                    ? 'Select Deadline' 
                    : 'Deadline: ${deadline!.day}/${deadline!.month}/${deadline!.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => deadline = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Assignment File URL'),
                  onChanged: (value) => assignmentFileUrl = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Solution File URL (Optional)'),
                  onChanged: (value) => solutionFileUrl = value,
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
                    deadline != null) {
                  try {
                    final assignmentData = {
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'subject': _selectedSubject!.name,
                      'category': _selectedCategory!.name,
                      'course': _selectedSubcategory!,
                      'totalMarks': int.parse(totalMarksController.text),
                      'deadline': deadline!.toIso8601String(),
                      'assignmentFileUrl': assignmentFileUrl,
                      'solutionFileUrl': solutionFileUrl,
                    };
                    
                    await _adminService.uploadAssignment(assignmentData);
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Assignment created successfully')),
                    );
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
      ),
    );
  }

  void _showAssignmentsListDialog() async {
    try {
      final assignments = await _subjectService.getAssignmentsForSubject(_selectedSubject!.name);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${_selectedSubject!.name} - Assignments'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: assignments.isEmpty
                ? const Center(child: Text('No assignments found'))
                : ListView.builder(
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];
                      final deadline = DateTime.parse(assignment['deadline']);
                      final isOverdue = deadline.isBefore(DateTime.now());
                      
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isOverdue ? Colors.red : Colors.green,
                            child: Text('${assignment['totalMarks']}'),
                          ),
                          title: Text(assignment['title']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(assignment['description']),
                              Text(
                                'Deadline: ${deadline.day}/${deadline.month}/${deadline.year}',
                                style: TextStyle(
                                  color: isOverdue ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () => _deleteAssignment(assignment['_id']),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Assignment',
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
        SnackBar(content: Text('Error loading assignments: $e')),
      );
    }
  }

  Future<void> _deleteAssignment(String assignmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text('Are you sure you want to delete this assignment?'),
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
        await _adminService.deleteAssignment(assignmentId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment deleted successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting assignment: $e')),
        );
      }
    }
  }
}