import 'package:flutter/material.dart';

import 'my_issues_screen.dart';
import 'report_issue_screen.dart';

class ReporterHomeScreen extends StatelessWidget {
  const ReporterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Facility AI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Report and track campus facility issues.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),

            _ActionCard(
              icon: Icons.add_circle_outline,
              title: 'Report an Issue',
              subtitle: 'Submit a new facility problem',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportIssueScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _ActionCard(
              icon: Icons.assignment_outlined,
              title: 'My Issues',
              subtitle: 'Track your reported issues',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyIssuesScreen(),
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}