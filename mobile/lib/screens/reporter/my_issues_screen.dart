import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/issue_provider.dart';
import '../../widgets/issue_card.dart';
import 'issue_details_screen.dart';

class MyIssuesScreen extends StatefulWidget {
  const MyIssuesScreen({super.key});

  @override
  State<MyIssuesScreen> createState() =>
      _MyIssuesScreenState();
}

class _MyIssuesScreenState extends State<MyIssuesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IssueProvider>().loadMyIssues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final issueProvider = context.watch<IssueProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Issues'),
      ),
      body: RefreshIndicator(
        onRefresh: issueProvider.loadMyIssues,
        child: _buildBody(issueProvider),
      ),
    );
  }

  Widget _buildBody(IssueProvider issueProvider) {
    if (issueProvider.isLoading &&
        issueProvider.issues.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (issueProvider.errorMessage != null &&
        issueProvider.issues.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 180),
          const Icon(
            Icons.cloud_off_outlined,
            size: 65,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            issueProvider.errorMessage!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Pull down to try again.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (issueProvider.issues.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          Icon(
            Icons.assignment_outlined,
            size: 70,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No issues reported yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your reported facility issues will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: issueProvider.issues.length,
      itemBuilder: (context, index) {
        final issue = issueProvider.issues[index];

        return IssueCard(
          issue: issue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    IssueDetailsScreen(issue: issue),
              ),
            );
          },
        );
      },
    );
  }
}