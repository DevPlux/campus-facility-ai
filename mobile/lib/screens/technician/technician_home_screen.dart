import 'package:flutter/material.dart';

import 'task_details_screen.dart';

class TechnicianHomeScreen extends StatelessWidget {
  const TechnicianHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Assigned Jobs',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'View and manage your assigned facility issues.',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Temporary task for UI testing.
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                child: Icon(Icons.plumbing),
              ),
              title: const Text(
                'Water Leakage',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Computer Lab 03\nASSIGNED',
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TaskDetailsScreen(),
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