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

  // ---------------------------------------------------------------------------
  // UI helpers (visual only)
  // ---------------------------------------------------------------------------

  Widget _buildHero(IssueProvider provider) {
    final total = provider.issues.length;

    final open = provider.issues
        .where((i) =>
            i.status.toLowerCase().contains('open') ||
            i.status.toLowerCase().contains('pending'))
        .length;

    final resolved = provider.issues
        .where((i) =>
            i.status.toLowerCase().contains('resolv') ||
            i.status.toLowerCase().contains('complete') ||
            i.status.toLowerCase().contains('done'))
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
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: back button + title
          Row(
            children: [
              Material(
                color: Colors.white.withOpacity(0.18),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'My Reports',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'MY ISSUES',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 11.5,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Track your reports',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Follow the progress of every facility issue you have submitted.',
            style: TextStyle(
              color: Color(0xE6FFFFFF),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),

          if (total > 0) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    label: 'Total',
                    value: total.toString(),
                    icon: Icons.list_alt_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    label: 'Open',
                    value: open.toString(),
                    icon: Icons.pending_actions_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    label: 'Resolved',
                    value: resolved.toString(),
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
              ],
            ),
          ],
        ],
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
        const SizedBox(height: 100),
        Center(
          child: Container(
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
        const SizedBox(height: 100),
        Center(
          child: Container(
            width: 90,
            height: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF0A84FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_rounded,
              size: 44,
              color: Color(0xFF0A84FF),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'No issues reported yet',
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
          'Your reported facility issues will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(IssueProvider issueProvider) {
    if (issueProvider.isLoading &&
        issueProvider.issues.isEmpty) {
      return _buildLoading();
    }

    if (issueProvider.errorMessage != null &&
        issueProvider.issues.isEmpty) {
      return _buildError(issueProvider.errorMessage!);
    }

    if (issueProvider.issues.isEmpty) {
      return _buildEmpty();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: issueProvider.issues.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              'Your reported issues',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2433),
                letterSpacing: -0.2,
              ),
            ),
          );
        }

        final issue = issueProvider.issues[index - 1];

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

  @override
  Widget build(BuildContext context) {
    final issueProvider = context.watch<IssueProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: RefreshIndicator(
        onRefresh: issueProvider.loadMyIssues,
        edgeOffset: 200,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHero(issueProvider),
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              child: _buildBody(issueProvider),
            ),
          ],
        ),
      ),
    );
  }
}