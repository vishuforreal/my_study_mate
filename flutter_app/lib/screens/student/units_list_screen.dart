import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/subject_model.dart';
import '../../services/subject_service.dart';

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
                        trailing: ElevatedButton(
                          onPressed: () => _openPDF(unit),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('View Notes'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _openPDF(Map<String, dynamic> unit) async {
    try {
      final pdfUrl = unit['pdfUrl'] ?? '';
      
      if (pdfUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF not available')),
        );
        return;
      }

      // Convert Google Drive link to direct view link if needed
      String finalUrl = pdfUrl;
      if (pdfUrl.contains('drive.google.com')) {
        final fileId = _extractGoogleDriveFileId(pdfUrl);
        if (fileId.isNotEmpty) {
          finalUrl = 'https://drive.google.com/file/d/$fileId/view';
        }
      }

      final Uri url = Uri.parse(finalUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PDF')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }



  String _extractGoogleDriveFileId(String url) {
    final regex = RegExp(r'/d/([a-zA-Z0-9-_]+)');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }
}