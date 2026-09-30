import 'package:flutter/material.dart';

import 'complete_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key});

  @override
  State<TaskDetailsScreen> createState() =>
      _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Water Leakage',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const _DetailRow(
              label: 'Location',
              value: 'Computer Lab 03',
            ),
            const _DetailRow(
              label: 'Category',
              value: 'PLUMBING',
            ),
            const _DetailRow(
              label: 'Priority',
              value: 'HIGH',
            ),
            _DetailRow(
              label: 'Status',
              value: _started ? 'IN PROGRESS' : 'ASSIGNED',
            ),

            const SizedBox(height: 24),

            const Text(
              'Problem Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Water leaking from the ceiling in Computer Lab 03.',
            ),

            const SizedBox(height: 24),

            const Text(
              'AI Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Possible ceiling pipe leakage. Inspect the water line above Lab 03.',
            ),

            const SizedBox(height: 30),

            if (!_started)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _started = true;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Work started'),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Work'),
              ),

            if (_started)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CompleteTaskScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Complete Task'),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}