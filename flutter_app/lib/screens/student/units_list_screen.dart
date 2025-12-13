import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/subject_model.dart';
import '../../services/subject_service.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import 'pdf_viewer_screen.dart';

class UnitsListScreen extends StatefulWidget {
  final SubjectModel subject;

  const UnitsListScreen({super.key, required this.subject});

  @override
  State<UnitsListScreen> createState() => _UnitsListScreenState();
}

class _UnitsListScreenState extends State<UnitsListScreen> {
  final SubjectService _subjectService = SubjectService();
  List<Map<String, dynamic>> _units = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    try {
      final units = await _subjectService.getUnitsForSubject(widget.subject.name);
      setState(() {
        _units = units;
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
      appBar: AppBar(title: Text('${widget.subject.name} - Units')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _units.isEmpty
              ? const Center(child: Text('No units available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _units.length,
                  itemBuilder: (context, index) {
                    final unit = _units[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            '${unit['unit']}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          unit['title'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('Unit ${unit['unit']} • PDF Notes'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => _openPDF(unit),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('View Notes'),
                            ),
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, _) {
                                if (authProvider.isAdmin || authProvider.isSuperAdmin) {
                                  return IconButton(
                                    onPressed: () => _deleteUnit(unit['unit']),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Delete Unit',
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _openPDF(Map<String, dynamic> unit) async {
    final pdfUrl = unit['pdfUrl'] ?? '';
    
    if (pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF not available')),
      );
      return;
    }

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
        final apiService = ApiService();
        await apiService.delete('/admin/notes/unit/${widget.subject.name}/$unitNumber');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unit $unitNumber deleted successfully')),
        );
        
        _loadUnits(); // Reload units
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting unit: $e')),
        );
      }
    }
  }




}