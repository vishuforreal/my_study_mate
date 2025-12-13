import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/subject_service.dart';
import '../../models/subject_model.dart';
import 'subject_selection_screen.dart';

// Books List Screen
class BooksListScreen extends StatefulWidget {
  const BooksListScreen({super.key});

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  @override
  Widget build(BuildContext context) {
    return BooksSubjectSelectionScreen();
  }
}

class BooksSubjectSelectionScreen extends StatefulWidget {
  @override
  State<BooksSubjectSelectionScreen> createState() => _BooksSubjectSelectionScreenState();
}

class _BooksSubjectSelectionScreenState extends State<BooksSubjectSelectionScreen> {
  final SubjectService _subjectService = SubjectService();
  List<SubjectModel> _subjects = [];
  List<SubjectModel> _filteredSubjects = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final subjects = await _subjectService.getSubjects();
      setState(() {
        _subjects = subjects;
        _filteredSubjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _filterSubjects(String query) {
    setState(() {
      _filteredSubjects = _subjects
          .where((subject) => subject.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Subject - Books')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search subjects',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filterSubjects,
                  ),
                ),
                Expanded(
                  child: _filteredSubjects.isEmpty
                      ? const Center(child: Text('No subjects found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = _filteredSubjects[index];
                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.book)),
                                title: Text(subject.name),
                                subtitle: Text(subject.subcategory),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BooksContentScreen(subject: subject),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class BooksContentScreen extends StatefulWidget {
  final SubjectModel subject;

  const BooksContentScreen({super.key, required this.subject});

  @override
  State<BooksContentScreen> createState() => _BooksContentScreenState();
}

class _BooksContentScreenState extends State<BooksContentScreen> {
  final SubjectService _subjectService = SubjectService();
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _subjectService.getBooksForSubject(widget.subject.name);
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.subject.name} - Books')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? const Center(child: Text('No books available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.book, color: Colors.white),
                        ),
                        title: Text(
                          book['title'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('Author: ${book['author']}'),
                        trailing: ElevatedButton(
                          onPressed: () => _openBook(book),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Read'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _openBook(Map<String, dynamic> book) async {
    final fileUrl = book['fileUrl'] ?? '';
    
    if (fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book file not available')),
      );
      return;
    }

    try {
      final Uri url = Uri.parse(fileUrl);
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening book: $e')),
      );
    }
  }
}

// PPTs List Screen
class PPTsListScreen extends StatefulWidget {
  const PPTsListScreen({super.key});

  @override
  State<PPTsListScreen> createState() => _PPTsListScreenState();
}

class _PPTsListScreenState extends State<PPTsListScreen> {
  @override
  Widget build(BuildContext context) {
    return PPTsSubjectSelectionScreen();
  }
}

class PPTsSubjectSelectionScreen extends StatefulWidget {
  @override
  State<PPTsSubjectSelectionScreen> createState() => _PPTsSubjectSelectionScreenState();
}

class _PPTsSubjectSelectionScreenState extends State<PPTsSubjectSelectionScreen> {
  final SubjectService _subjectService = SubjectService();
  List<SubjectModel> _subjects = [];
  List<SubjectModel> _filteredSubjects = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final subjects = await _subjectService.getSubjects();
      setState(() {
        _subjects = subjects;
        _filteredSubjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _filterSubjects(String query) {
    setState(() {
      _filteredSubjects = _subjects
          .where((subject) => subject.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Subject - PPTs')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search subjects',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filterSubjects,
                  ),
                ),
                Expanded(
                  child: _filteredSubjects.isEmpty
                      ? const Center(child: Text('No subjects found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = _filteredSubjects[index];
                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.slideshow)),
                                title: Text(subject.name),
                                subtitle: Text(subject.subcategory),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PPTsContentScreen(subject: subject),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class PPTsContentScreen extends StatefulWidget {
  final SubjectModel subject;

  const PPTsContentScreen({super.key, required this.subject});

  @override
  State<PPTsContentScreen> createState() => _PPTsContentScreenState();
}

class _PPTsContentScreenState extends State<PPTsContentScreen> {
  final SubjectService _subjectService = SubjectService();
  List<Map<String, dynamic>> _ppts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPPTs();
  }

  Future<void> _loadPPTs() async {
    try {
      final ppts = await _subjectService.getPPTsForSubject(widget.subject.name);
      setState(() {
        _ppts = ppts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.subject.name} - PPTs')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ppts.isEmpty
              ? const Center(child: Text('No PPTs available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ppts.length,
                  itemBuilder: (context, index) {
                    final ppt = _ppts[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.slideshow, color: Colors.white),
                        ),
                        title: Text(
                          ppt['title'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(ppt['description'] ?? ''),
                        trailing: ElevatedButton(
                          onPressed: () => _openPPT(ppt),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('View'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _openPPT(Map<String, dynamic> ppt) async {
    final fileUrl = ppt['fileUrl'] ?? '';
    
    if (fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PPT file not available')),
      );
      return;
    }

    try {
      final Uri url = Uri.parse(fileUrl);
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PPT: $e')),
      );
    }
  }
}

// Projects List Screen
class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
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
      appBar: AppBar(title: const Text('Project Categories')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.code)),
              title: Text(category),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectsCategoryScreen(category: category),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ProjectsCategoryScreen extends StatefulWidget {
  final String category;

  const ProjectsCategoryScreen({super.key, required this.category});

  @override
  State<ProjectsCategoryScreen> createState() => _ProjectsCategoryScreenState();
}

class _ProjectsCategoryScreenState extends State<ProjectsCategoryScreen> {
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    // Mock data for now - replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _projects = [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.category} Projects')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? const Center(child: Text('No projects available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Icon(Icons.code, color: Colors.white),
                        ),
                        title: Text(project['title']),
                        subtitle: Text('Tech: ${project['technology']}'),
                        trailing: ElevatedButton(
                          onPressed: () => _openProject(project),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Download'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _openProject(Map<String, dynamic> project) async {
    final fileUrl = project['fileUrl'] ?? '';
    
    if (fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project file not available')),
      );
      return;
    }

    try {
      final Uri url = Uri.parse(fileUrl);
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening project: $e')),
      );
    }
  }
}

// Assignments List Screen
class AssignmentsListScreen extends StatefulWidget {
  const AssignmentsListScreen({super.key});

  @override
  State<AssignmentsListScreen> createState() => _AssignmentsListScreenState();
}

class _AssignmentsListScreenState extends State<AssignmentsListScreen> {
  @override
  Widget build(BuildContext context) {
    return AssignmentsSubjectSelectionScreen();
  }
}

class AssignmentsSubjectSelectionScreen extends StatefulWidget {
  @override
  State<AssignmentsSubjectSelectionScreen> createState() => _AssignmentsSubjectSelectionScreenState();
}

class _AssignmentsSubjectSelectionScreenState extends State<AssignmentsSubjectSelectionScreen> {
  final SubjectService _subjectService = SubjectService();
  List<SubjectModel> _subjects = [];
  List<SubjectModel> _filteredSubjects = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final subjects = await _subjectService.getSubjects();
      setState(() {
        _subjects = subjects;
        _filteredSubjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _filterSubjects(String query) {
    setState(() {
      _filteredSubjects = _subjects
          .where((subject) => subject.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Subject - Assignments')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search subjects',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filterSubjects,
                  ),
                ),
                Expanded(
                  child: _filteredSubjects.isEmpty
                      ? const Center(child: Text('No subjects found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = _filteredSubjects[index];
                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.assignment)),
                                title: Text(subject.name),
                                subtitle: Text(subject.subcategory),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AssignmentsContentScreen(subject: subject),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class AssignmentsContentScreen extends StatefulWidget {
  final SubjectModel subject;

  const AssignmentsContentScreen({super.key, required this.subject});

  @override
  State<AssignmentsContentScreen> createState() => _AssignmentsContentScreenState();
}

class _AssignmentsContentScreenState extends State<AssignmentsContentScreen> {
  final SubjectService _subjectService = SubjectService();
  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      final assignments = await _subjectService.getAssignmentsForSubject(widget.subject.name);
      setState(() {
        _assignments = assignments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.subject.name} - Assignments')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assignments.isEmpty
              ? const Center(child: Text('No assignments available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = _assignments[index];
                    final deadline = DateTime.parse(assignment['deadline']);
                    final isOverdue = deadline.isBefore(DateTime.now());
                    
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isOverdue ? Colors.red : Colors.green,
                          child: Text('${assignment['totalMarks']}'),
                        ),
                        title: Text(
                          assignment['title'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
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
                        trailing: ElevatedButton(
                          onPressed: () => _openAssignment(assignment),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOverdue ? Colors.red : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('View'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _openAssignment(Map<String, dynamic> assignment) async {
    final fileUrl = assignment['assignmentFileUrl'] ?? '';
    
    if (fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment file not available')),
      );
      return;
    }

    try {
      final Uri url = Uri.parse(fileUrl);
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening assignment: $e')),
      );
    }
  }
}

// Tests List Screen (keeping existing implementation)
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
