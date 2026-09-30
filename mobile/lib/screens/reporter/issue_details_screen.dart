import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/issue.dart';

class IssueDetailsScreen extends StatelessWidget {
  final Issue issue;

  const IssueDetailsScreen({
    super.key,
    required this.issue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              issue.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _DetailRow(
              label: 'Status',
              value: issue.status.replaceAll('_', ' '),
            ),
            _DetailRow(
              label: 'Location',
              value: issue.location,
            ),
            _DetailRow(
              label: 'Reported',
              value: DateFormat(
                'dd MMM yyyy, hh:mm a',
              ).format(issue.createdAt.toLocal()),
            ),

            if (issue.category != null)
              _DetailRow(
                label: 'Category',
                value: issue.category!,
              ),

            if (issue.priority != null)
              _DetailRow(
                label: 'Priority',
                value: issue.priority!,
              ),

            const SizedBox(height: 20),

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(issue.description),

            if (issue.aiSummary != null) ...[
              const SizedBox(height: 24),
              const Text(
                'AI Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(issue.aiSummary!),
            ],

            if (issue.beforeImageUrl != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Before Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  issue.beforeImageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return const SizedBox(
                      height: 120,
                      child: Center(
                        child: Text('Unable to load image'),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (issue.afterImageUrl != null) ...[
              const SizedBox(height: 24),
              const Text(
                'After Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  issue.afterImageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ],
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
            width: 95,
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