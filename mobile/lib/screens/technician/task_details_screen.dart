import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/assignment.dart';
import '../../providers/assignment_provider.dart';
import 'complete_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Assignment assignment;

  const TaskDetailsScreen({
    super.key,
    required this.assignment,
  });

  @override
  State<TaskDetailsScreen> createState() =>
      _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.assignment.status;
  }

  Future<void> _startWork() async {
    final provider = context.read<AssignmentProvider>();

    final success = await provider.startTask(
      widget.assignment.id,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _status = AppConstants.statusInProgress;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Work started successfully.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Unable to start task.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();
    final issue = widget.assignment.issue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              issue?.title ?? 'Facility Issue',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _DetailRow(
              label: 'Location',
              value: issue?.location ?? 'Not available',
            ),

            if (issue?.category != null)
              _DetailRow(
                label: 'Category',
                value: issue!.category!,
              ),

            if (issue?.priority != null)
              _DetailRow(
                label: 'Priority',
                value: issue!.priority!,
              ),

            _DetailRow(
              label: 'Status',
              value: _status.replaceAll('_', ' '),
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

            Text(
              issue?.description ??
                  'No description available.',
            ),

            if (issue?.aiSummary != null) ...[
              const SizedBox(height: 24),
              const Text(
                'AI Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(issue!.aiSummary!),
            ],

            if (issue?.beforeImageUrl != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Reported Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  issue!.beforeImageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return const SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                          'Unable to load image',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (widget.assignment.aiReason != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Assignment Reason',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.assignment.aiReason!),
            ],

            const SizedBox(height: 30),

            if (_status == AppConstants.statusAssigned)
              ElevatedButton.icon(
                onPressed:
                    provider.isLoading ? null : _startWork,
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  provider.isLoading
                      ? 'Starting...'
                      : 'Start Work',
                ),
              ),

            if (_status == AppConstants.statusInProgress)
              ElevatedButton.icon(
                onPressed: () async {
                  final completed =
                      await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CompleteTaskScreen(
                        assignmentId:
                            widget.assignment.id,
                      ),
                    ),
                  );

                  if (!mounted) return;

                  if (completed == true) {
                    setState(() {
                      _status =
                          AppConstants.statusCompleted;
                    });
                  }
                },
                icon: const Icon(
                  Icons.check_circle_outline,
                ),
                label: const Text('Complete Task'),
              ),

            if (_status == AppConstants.statusCompleted)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Task Completed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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