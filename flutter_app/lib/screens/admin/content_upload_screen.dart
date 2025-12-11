import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/category_service.dart';
import '../../services/subject_service.dart';
import '../../services/admin_service.dart';
import '../../models/category_model.dart';
import 'dart:io';

class ContentUploadScreen extends StatefulWidget {
  final String contentType;

  const ContentUploadScreen({super.key, required this.contentType});

  @override
  State<ContentUploadScreen> createState() => _ContentUploadScreenState();
}

class _ContentUploadScreenState extends State<ContentUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final CategoryService _categoryService = CategoryService();
  final SubjectService _subjectService = SubjectService();
  final AdminService _adminService = AdminService();

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();
  final _unitController = TextEditingController();
  final _chapterController = TextEditingController();
  final _priceController = TextEditingController();

  // Dropdowns
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  String? _selectedSubcategory;
  List<SubjectModel> _subjects = [];
  SubjectModel? _selectedSubject;
  String? _newSubjectName;

  // Files
  File? _mainFile;
  File? _secondaryFile;
  File? _coverImage;

  // Other fields
  bool _isPaid = false;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _unitController.dispose();
    _chapterController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
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
        SnackBar(content: Text('Error loading subjects: $e')),
      );
    }
  }

  Future<void> _pickFile(String fileType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        if (fileType == 'main') {
          _mainFile = File(result.files.single.path!);
        } else if (fileType == 'secondary') {
          _secondaryFile = File(result.files.single.path!);
        } else if (fileType == 'cover') {
          _coverImage = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> _createSubject() async {
    if (_newSubjectName == null || _newSubjectName!.isEmpty) return;

    try {
      await _subjectService.createSubject(
        _newSubjectName!,
        _selectedCategory!.id,
        _selectedSubcategory!,
      );
      await _loadSubjects();
      setState(() => _newSubjectName = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating subject: $e')),
      );
    }
  }

  Future<void> _uploadContent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mainFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory!.id,
        'subcategory': _selectedSubcategory!,
        'subject': _selectedSubject?.name ?? '',
        'isPaid': _isPaid.toString(),
        'price': _isPaid ? _priceController.text : '0',
      };

      // Add content-specific fields
      if (widget.contentType == 'notes') {
        data['unit'] = _unitController.text.trim();
        data['chapter'] = _chapterController.text.trim();
        data['notesFile'] = _mainFile!;
        if (_secondaryFile != null) data['questionsFile'] = _secondaryFile!;
      } else if (widget.contentType == 'books') {
        data['author'] = _authorController.text.trim();
        data['bookFile'] = _mainFile!;
        if (_coverImage != null) data['coverImage'] = _coverImage!;
      } else if (widget.contentType == 'tests') {
        // For tests, we'll need a different approach as it's JSON data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test creation not implemented yet')),
        );
        return;
      } else if (widget.contentType == 'ppts') {
        data['pptFile'] = _mainFile!;
      } else if (widget.contentType == 'projects') {
        data['projectFile'] = _mainFile!;
        data['tags'] = '[]'; // Empty tags for now
      } else if (widget.contentType == 'assignments') {
        data['assignmentFile'] = _mainFile!;
        if (_secondaryFile != null) data['solutionFile'] = _secondaryFile!;
      }

      // Upload based on content type
      switch (widget.contentType) {
        case 'notes':
          await _adminService.uploadNote(data);
          break;
        case 'books':
          await _adminService.uploadBook(data);
          break;
        case 'ppts':
          await _adminService.uploadPPT(data);
          break;
        case 'projects':
          await _adminService.uploadProject(data);
          break;
        case 'assignments':
          await _adminService.uploadAssignment(data);
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.contentType.toUpperCase()} uploaded successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload ${widget.contentType.toUpperCase()}'),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text('No categories available. Please create categories first.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          validator: (value) => value == null ? 'Please select a category' : null,
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
                            validator: (value) => value == null ? 'Please select a subcategory' : null,
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
                          const SizedBox(height: 16),
                        ],

                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (value) => value?.isEmpty ?? true ? 'Please enter title' : null,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Author (for books)
                        if (widget.contentType == 'books') ...[
                          TextFormField(
                            controller: _authorController,
                            decoration: const InputDecoration(labelText: 'Author'),
                            validator: (value) => value?.isEmpty ?? true ? 'Please enter author' : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Unit and Chapter (for notes)
                        if (widget.contentType == 'notes') ...[
                          TextFormField(
                            controller: _unitController,
                            decoration: const InputDecoration(labelText: 'Unit'),
                            validator: (value) => value?.isEmpty ?? true ? 'Please enter unit' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _chapterController,
                            decoration: const InputDecoration(labelText: 'Chapter'),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // File Selection
                        _buildFileSelector(),

                        // Secondary File (for notes - questions, assignments - solutions)
                        if (widget.contentType == 'notes' || widget.contentType == 'assignments')
                          _buildSecondaryFileSelector(),

                        // Cover Image (for books)
                        if (widget.contentType == 'books')
                          _buildCoverImageSelector(),

                        // Paid Content
                        SwitchListTile(
                          title: const Text('Paid Content'),
                          value: _isPaid,
                          onChanged: (value) => setState(() => _isPaid = value),
                        ),

                        if (_isPaid) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(labelText: 'Price'),
                            keyboardType: TextInputType.number,
                            validator: (value) => _isPaid && (value?.isEmpty ?? true) ? 'Please enter price' : null,
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Upload Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _uploadContent,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text('Upload ${widget.contentType.toUpperCase()}'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFileSelector() {
    String fileType = _getMainFileType();
    return Card(
      child: ListTile(
        leading: const Icon(Icons.attach_file),
        title: Text(_mainFile?.path.split('/').last ?? 'Select $fileType'),
        trailing: const Icon(Icons.folder_open),
        onTap: () => _pickFile('main'),
      ),
    );
  }

  Widget _buildSecondaryFileSelector() {
    String fileType = widget.contentType == 'notes' ? 'Questions File' : 'Solution File';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.attach_file),
        title: Text(_secondaryFile?.path.split('/').last ?? 'Select $fileType (Optional)'),
        trailing: const Icon(Icons.folder_open),
        onTap: () => _pickFile('secondary'),
      ),
    );
  }

  Widget _buildCoverImageSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.image),
        title: Text(_coverImage?.path.split('/').last ?? 'Select Cover Image (Optional)'),
        trailing: const Icon(Icons.folder_open),
        onTap: () => _pickFile('cover'),
      ),
    );
  }

  String _getMainFileType() {
    switch (widget.contentType) {
      case 'notes':
        return 'Notes File';
      case 'books':
        return 'Book File';
      case 'ppts':
        return 'PPT File';
      case 'projects':
        return 'Project File';
      case 'assignments':
        return 'Assignment File';
      default:
        return 'File';
    }
  }

  void _showCreateSubjectDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Subject'),
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
            onPressed: () {
              setState(() => _newSubjectName = controller.text.trim());
              Navigator.pop(context);
              _createSubject();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}