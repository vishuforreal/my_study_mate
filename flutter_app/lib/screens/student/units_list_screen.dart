import 'package:flutter/material.dart';
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
                          child: Text('${unit['unit']}'),
                        ),
                        title: Text(unit['title']),
                        subtitle: const Text('PDF Available'),
                        trailing: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening Unit ${unit['unit']} PDF')),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}