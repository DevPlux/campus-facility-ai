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

  IconData _statusIcon(String status) {
    final s = status.toLowerCase();

    if (s.contains('complete') || s.contains('done') || s.contains('resolve')) {
      return Icons.check_circle_rounded;
    }
    if (s.contains('progress') || s.contains('ongoing')) {
      return Icons.play_circle_rounded;
    }
    if (s.contains('pending') || s.contains('assign')) {
      return Icons.hourglass_bottom_rounded;
    }
    if (s.contains('cancel') || s.contains('reject')) {
      return Icons.cancel_rounded;
    }
    return Icons.circle_outlined;
  }

  Color _priorityColor(String? priority) {
    final p = (priority ?? '').toLowerCase();
    if (p.contains('high') || p.contains('urgent') || p.contains('critical')) {
      return const Color(0xFFFF3B30);
    }
    if (p.contains('medium') || p.contains('normal')) {
      return const Color(0xFFFF9500);
    }
    if (p.contains('low')) {
      return const Color(0xFF34C759);
    }
    return const Color(0xFF8E8E93);
  }

  Widget _buildHeroHeader(dynamic issue) {
    final statusColor = _statusColor(_status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor,
            Color.lerp(statusColor, Colors.black, 0.35)!,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.28),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back button
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
              // Status chip in hero
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _statusIcon(_status),
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _prettyStatus(_status),
                      style: const TextStyle(
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

          const SizedBox(height: 26),

          const Text(
            'TASK DETAILS',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 11.5,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            issue?.title ?? 'Facility Issue',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),

          if (issue?.location != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xE6FFFFFF),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    issue!.location,
                    style: const TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section / card widgets
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8E8E93),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = const Color(0xFF007AFF),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8E8E93),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2433),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFF0F2F5),
      ),
    );
  }

  Widget _textSection(String title, String body, {IconData? icon}) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: const Color(0xFF007AFF)),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2433),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action buttons
  // ---------------------------------------------------------------------------

  Widget _gradientButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required List<Color> colors,
    bool loading = false,
  }) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: onPressed == null
                ? [colors.first.withOpacity(0.5), colors.last.withOpacity(0.5)]
                : colors,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: onPressed == null
              ? null
              : [
                  BoxShadow(
                    color: colors.first.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(icon, size: 20),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _completedBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF34C759), Color(0xFF28A745)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3334C759),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Completed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Great work! This task is now closed.',
                  style: TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();
    final issue = widget.assignment.issue;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(issue),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------------------------
                  // Info group
                  // -----------------------------------------------
                  _sectionTitle('Overview'),
                  _card(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          icon: Icons.location_on_rounded,
                          label: 'Location',
                          value: issue?.location ?? 'Not available',
                          iconColor: const Color(0xFFFF3B30),
                        ),
                        if (issue?.category != null) ...[
                          _divider(),
                          _infoRow(
                            icon: Icons.category_rounded,
                            label: 'Category',
                            value: issue!.category!,
                            iconColor: const Color(0xFF5856D6),
                          ),
                        ],
                        if (issue?.priority != null) ...[
                          _divider(),
                          _infoRow(
                            icon: Icons.flag_rounded,
                            label: 'Priority',
                            value: issue!.priority!,
                            iconColor: _priorityColor(issue.priority),
                          ),
                        ],
                        _divider(),
                        _infoRow(
                          icon: _statusIcon(_status),
                          label: 'Status',
                          value: _prettyStatus(_status),
                          iconColor: _statusColor(_status),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // -----------------------------------------------
                  // Description
                  // -----------------------------------------------
                  _sectionTitle('Problem Description'),
                  _textSection(
                    'Reported Issue',
                    issue?.description ?? 'No description available.',
                    icon: Icons.description_outlined,
                  ),

                  // -----------------------------------------------
                  // AI Analysis
                  // -----------------------------------------------
                  if (issue?.aiSummary != null) ...[
                    const SizedBox(height: 22),
                    _sectionTitle('AI Analysis'),
                    _textSection(
                      'AI Summary',
                      issue!.aiSummary!,
                      icon: Icons.auto_awesome_rounded,
                    ),
                  ],

                  // -----------------------------------------------
                  // Reported photo
                  // -----------------------------------------------
                  if (issue?.beforeImageUrl != null) ...[
                    const SizedBox(height: 22),
                    _sectionTitle('Reported Photo'),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x18000000),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.network(
                          issue!.beforeImageUrl!,
                          width: double.infinity,
                          height: 230,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return Container(
                              height: 160,
                              color: const Color(0xFFF2F4F8),
                              alignment: Alignment.center,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 40,
                                    color: Color(0xFF8E8E93),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Unable to load image',
                                    style: TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // -----------------------------------------------
                  // Assignment reason
                  // -----------------------------------------------
                  if (widget.assignment.aiReason != null) ...[
                    const SizedBox(height: 22),
                    _sectionTitle('Assignment Reason'),
                    _textSection(
                      'Why you were assigned',
                      widget.assignment.aiReason!,
                      icon: Icons.info_outline_rounded,
                    ),
                  ],

                  const SizedBox(height: 30),

                  // -----------------------------------------------
                  // Action buttons
                  // -----------------------------------------------
                  if (_status == AppConstants.statusAssigned)
                    _gradientButton(
                      onPressed: provider.isLoading ? null : _startWork,
                      icon: Icons.play_arrow_rounded,
                      label: provider.isLoading
                          ? 'Starting...'
                          : 'Start Work',
                      colors: const [Color(0xFF0A84FF), Color(0xFF0066CC)],
                      loading: provider.isLoading,
                    ),

                  if (_status == AppConstants.statusInProgress)
                    _gradientButton(
                      onPressed: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CompleteTaskScreen(
                              assignmentId: widget.assignment.id,
                            ),
                          ),
                        );

                        if (!mounted) return;

                        if (completed == true) {
                          setState(() {
                            _status = AppConstants.statusCompleted;
                          });
                        }
                      },
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Complete Task',
                      colors: const [Color(0xFF34C759), Color(0xFF28A745)],
                    ),

                  if (_status == AppConstants.statusCompleted)
                    _completedBanner(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}