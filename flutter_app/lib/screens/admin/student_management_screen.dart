import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/user_model.dart';
import '../../config/constants.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final AdminService _adminService = AdminService();
  List<UserModel> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await _adminService.getStudents();
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _toggleBlockStatus(UserModel student) async {
    try {
      final response = await _adminService.toggleStudentBlock(student.id);
      await _loadStudents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student ${student.isBlocked ? 'unblocked' : 'blocked'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(child: Text('No students found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: student.isBlocked ? Colors.red : Colors.green,
                          child: Text(student.name[0].toUpperCase()),
                        ),
                        title: Text(student.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.email),
                            Text('Category: ${student.category}${student.subcategory != null ? ' - ${student.subcategory}' : ''}'),
                            Text('Status: ${student.isBlocked ? 'Blocked' : 'Active'}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'block',
                              child: Text(student.isBlocked ? 'Unblock' : 'Block'),
                            ),
                            const PopupMenuItem(
                              value: 'permissions',
                              child: Text('Permissions'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'block') {
                              _toggleBlockStatus(student);
                            } else if (value == 'permissions') {
                              _showPermissionsDialog(student);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showPermissionsDialog(UserModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${student.name} Permissions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Notes'),
              value: student.permissions.canAccessNotes,
              onChanged: (value) => _updatePermission(student, 'canAccessNotes', value!),
            ),
            CheckboxListTile(
              title: const Text('Books'),
              value: student.permissions.canAccessBooks,
              onChanged: (value) => _updatePermission(student, 'canAccessBooks', value!),
            ),
            CheckboxListTile(
              title: const Text('Tests'),
              value: student.permissions.canAccessTests,
              onChanged: (value) => _updatePermission(student, 'canAccessTests', value!),
            ),
            CheckboxListTile(
              title: const Text('PPTs'),
              value: student.permissions.canAccessPPTs,
              onChanged: (value) => _updatePermission(student, 'canAccessPPTs', value!),
            ),
            CheckboxListTile(
              title: const Text('Projects'),
              value: student.permissions.canAccessProjects,
              onChanged: (value) => _updatePermission(student, 'canAccessProjects', value!),
            ),
            CheckboxListTile(
              title: const Text('Assignments'),
              value: student.permissions.canAccessAssignments,
              onChanged: (value) => _updatePermission(student, 'canAccessAssignments', value!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePermission(UserModel student, String permission, bool value) async {
    try {
      await _adminService.updateStudentPermissions(student.id, {permission: value});
      await _loadStudents();
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissions updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}