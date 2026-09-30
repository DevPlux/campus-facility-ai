import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/assignment_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'task_details_screen.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() =>
      _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState
    extends State<TechnicianHomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentProvider>().loadMyTasks();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadMyTasks,
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(AssignmentProvider provider) {
    if (provider.isLoading &&
        provider.assignments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null &&
        provider.assignments.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 160),
          const Icon(
            Icons.cloud_off_outlined,
            size: 65,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage!,
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

    if (provider.assignments.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 160),
          Icon(
            Icons.engineering_outlined,
            size: 70,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No assigned tasks',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your assigned facility jobs will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: provider.assignments.length,
      itemBuilder: (context, index) {
        final assignment = provider.assignments[index];
        final issue = assignment.issue;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              child: Icon(Icons.build_outlined),
            ),
            title: Text(
              issue?.title ?? 'Facility Issue',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${issue?.location ?? 'Location unavailable'}\n'
                '${assignment.status.replaceAll('_', ' ')}',
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
                  builder: (_) => TaskDetailsScreen(
                    assignment: assignment,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}