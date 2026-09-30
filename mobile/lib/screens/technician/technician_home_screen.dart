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

  // ---------------------------------------------------------------------------
  // UI helpers (visual only)
  // ---------------------------------------------------------------------------

  Color _statusColor(String status) {
    final s = status.toLowerCase();

    if (s.contains('complete') || s.contains('done') || s.contains('resolve')) {
      return const Color(0xFF34C759); // iOS green
    }
    if (s.contains('progress') || s.contains('ongoing')) {
      return const Color(0xFF007AFF); // iOS blue
    }
    if (s.contains('pending') || s.contains('assign')) {
      return const Color(0xFFFF9500); // iOS orange
    }
    if (s.contains('cancel') || s.contains('reject')) {
      return const Color(0xFFFF3B30); // iOS red
    }
    return const Color(0xFF8E8E93); // iOS grey
  }

  String _prettyStatus(String status) {
    final cleaned = status.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return 'Unknown';
    return cleaned
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _prettyStatus(status),
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Hero section
  // ---------------------------------------------------------------------------

  Widget _buildHero(AssignmentProvider provider) {
    final total = provider.assignments.length;

    final pending = provider.assignments
        .where((a) => a.status.toLowerCase().contains('pending') ||
            a.status.toLowerCase().contains('assign'))
        .length;

    final inProgress = provider.assignments
        .where((a) => a.status.toLowerCase().contains('progress') ||
            a.status.toLowerCase().contains('ongoing'))
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A84FF),
            Color(0xFF0066CC),
            Color(0xFF003D80),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x330A84FF),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: greeting + logout
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'My Tasks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              _heroIconButton(
                icon: Icons.logout_rounded,
                tooltip: 'Logout',
                onTap: _logout,
              ),
            ],
          ),

          const SizedBox(height: 26),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _statCard(
                  label: 'Total',
                  value: total.toString(),
                  icon: Icons.assignment_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  label: 'Pending',
                  value: pending.toString(),
                  icon: Icons.hourglass_bottom_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  label: 'Active',
                  value: inProgress.toString(),
                  icon: Icons.play_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.18),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 11.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Task card
  // ---------------------------------------------------------------------------

  Widget _buildTaskCard(dynamic assignment) {
    final issue = assignment.issue;
    final statusColor = _statusColor(assignment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        statusColor.withOpacity(0.9),
                        statusColor.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue?.title ?? 'Facility Issue',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          color: Color(0xFF1A2433),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF8E8E93),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              issue?.location ?? 'Location unavailable',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _statusChip(assignment.status),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 6, top: 12),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: Color(0xFFC7C7CC),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty / Error / Loading states
  // ---------------------------------------------------------------------------

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 140),
        Container(
          width: 90,
          height: 90,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFF3B30).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: Color(0xFFFF3B30),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Something went wrong',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2433),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pull down to try again.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 140),
        Container(
          width: 90,
          height: 90,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF0A84FF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.engineering_rounded,
            size: 44,
            color: Color(0xFF0A84FF),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'No assigned tasks',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2433),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your assigned facility jobs will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  Widget _buildBody(AssignmentProvider provider) {
    if (provider.isLoading && provider.assignments.isEmpty) {
      return _buildLoading();
    }

    if (provider.errorMessage != null && provider.assignments.isEmpty) {
      return _buildError(provider.errorMessage!);
    }

    if (provider.assignments.isEmpty) {
      return _buildEmpty();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: provider.assignments.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              'Assigned to you',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2433),
                letterSpacing: -0.2,
              ),
            ),
          );
        }

        final assignment = provider.assignments[index - 1];
        return _buildTaskCard(assignment);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: RefreshIndicator(
        onRefresh: provider.loadMyTasks,
        edgeOffset: 200,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHero(provider),
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              child: _buildBody(provider),
            ),
          ],
        ),
      ),
    );
  }
}