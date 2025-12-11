import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../config/constants.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final analytics = await _adminService.getAnalytics();
      setState(() {
        _analytics = analytics;
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
      appBar: AppBar(title: const Text('Analytics')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Overview',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    // Students Stats
                    if (_analytics['students'] != null) ...[
                      _StatsCard(
                        title: 'Students',
                        stats: [
                          _StatItem('Total', _analytics['students']['total']?.toString() ?? '0'),
                          _StatItem('Active', _analytics['students']['active']?.toString() ?? '0'),
                          _StatItem('Blocked', _analytics['students']['blocked']?.toString() ?? '0'),
                        ],
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Content Stats
                    if (_analytics['content'] != null) ...[
                      _StatsCard(
                        title: 'Content',
                        stats: [
                          _StatItem('Notes', _analytics['content']['notes']?.toString() ?? '0'),
                          _StatItem('Books', _analytics['content']['books']?.toString() ?? '0'),
                          _StatItem('Tests', _analytics['content']['tests']?.toString() ?? '0'),
                          _StatItem('PPTs', _analytics['content']['ppts']?.toString() ?? '0'),
                          _StatItem('Projects', _analytics['content']['projects']?.toString() ?? '0'),
                          _StatItem('Assignments', _analytics['content']['assignments']?.toString() ?? '0'),
                        ],
                        color: Colors.green,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final List<_StatItem> stats;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.stats,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final stat = stats[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stat.value,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        stat.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;

  _StatItem(this.label, this.value);
}