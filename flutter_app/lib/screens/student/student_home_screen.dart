import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/constants.dart';
import 'notes_list_screen.dart';
import 'books_list_screen.dart';
import 'tests_list_screen.dart';
import 'ppts_list_screen.dart';
import 'projects_list_screen.dart';
import 'assignments_list_screen.dart';
import 'profile_screen.dart';
import '../common/no_access_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const StudentDashboard(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Study Mate'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                gradient: AppConstants.primaryGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: user?.profilePhoto != null
                        ? ClipOval(
                            child: Image.network(
                              user!.profilePhoto!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person, size: 30, color: AppConstants.primaryColor);
                              },
                            ),
                          )
                        : const Icon(Icons.person, size: 30, color: AppConstants.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        Text(
                          user?.name ?? 'Student',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          user?.course ?? '',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Content Categories
            Text(
              'Study Materials',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _ContentCard(
                  title: 'Notes',
                  icon: Icons.note_outlined,
                  color: Colors.blue,
                  onTap: () {
                    if (user?.permissions.canAccessNotes ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotesListScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NoAccessScreen(contentType: 'Notes')),
                      );
                    }
                  },
                ),
                _ContentCard(
                  title: 'Books',
                  icon: Icons.menu_book_outlined,
                  color: Colors.green,
                  onTap: () {
                    if (user?.permissions.canAccessBooks ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BooksListScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NoAccessScreen(contentType: 'Books')),
                      );
                    }
                  },
                ),
                _ContentCard(
                  title: 'Tests',
                  icon: Icons.quiz_outlined,
                  color: Colors.orange,
                  onTap: () {
                    if (user?.permissions.canAccessTests ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TestsListScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NoAccessScreen(contentType: 'Tests')),
                      );
                    }
                  },
                ),
                _ContentCard(
                  title: 'PPTs',
                  icon: Icons.slideshow_outlined,
                  color: Colors.purple,
                  onTap: () {
                    if (user?.permissions.canAccessPPTs ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PPTsListScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NoAccessScreen(contentType: 'PPTs')),
                      );
                    }
                  },
                ),
                _ContentCard(
                  title: 'Projects',
                  icon: Icons.code_outlined,
                  color: Colors.teal,
                  onTap: () {
                    if (user?.permissions.canAccessProjects ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProjectsListScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NoAccessScreen(contentType: 'Projects')),
                      );
                    }
                  },
                ),
                _ContentCard(
                  title: 'Assignments',
                  icon: Icons.assignment_outlined,
                  color: Colors.red,
                  onTap: () {
                    if (user?.permissions.canAccessAssignments ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AssignmentsListScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NoAccessScreen(contentType: 'Assignments')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ContentCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
