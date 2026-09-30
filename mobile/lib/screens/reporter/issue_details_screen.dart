import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/issue.dart';

class IssueDetailsScreen extends StatelessWidget {
  final Issue issue;

  const IssueDetailsScreen({
    super.key,
    required this.issue,
  });

  // ---------------------------------------------------------------------------
  // UI helpers (visual only)
  // ---------------------------------------------------------------------------

  Color _statusColor(String status) {
    final s = status.toLowerCase();

    if (s.contains('resolv') || s.contains('complete') || s.contains('done')) {
      return const Color(0xFF34C759); // iOS green
    }
    if (s.contains('progress') || s.contains('ongoing')) {
      return const Color(0xFF007AFF); // iOS blue
    }
    if (s.contains('pending') || s.contains('open') || s.contains('assign')) {
      return const Color(0xFFFF9500); // iOS orange
    }
    if (s.contains('cancel') || s.contains('reject')) {
      return const Color(0xFFFF3B30); // iOS red
    }
    return const Color(0xFF8E8E93); // iOS grey
  }

  IconData _statusIcon(String status) {
    final s = status.toLowerCase();

    if (s.contains('resolv') || s.contains('complete') || s.contains('done')) {
      return Icons.check_circle_rounded;
    }
    if (s.contains('progress') || s.contains('ongoing')) {
      return Icons.play_circle_rounded;
    }
    if (s.contains('pending') || s.contains('open') || s.contains('assign')) {
      return Icons.hourglass_bottom_rounded;
    }
    if (s.contains('cancel') || s.contains('reject')) {
      return Icons.cancel_rounded;
    }
    return Icons.circle_outlined;
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

  Widget _buildHero(BuildContext context) {
    final statusColor = _statusColor(issue.status);

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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _statusIcon(issue.status),
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _prettyStatus(issue.status),
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
            'ISSUE DETAILS',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 11.5,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            issue.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),

          if (issue.location.isNotEmpty) ...[
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
                    issue.location,
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

  Widget _imageCard(String url, {bool withError = false}) {
    return ClipRRect(
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
          url,
          width: double.infinity,
          height: 230,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            if (!withError) {
              return const SizedBox.shrink();
            }
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(context),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------------------------
                  // Overview
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
                          icon: _statusIcon(issue.status),
                          label: 'Status',
                          value: _prettyStatus(issue.status),
                          iconColor: _statusColor(issue.status),
                        ),
                        _divider(),
                        _infoRow(
                          icon: Icons.location_on_rounded,
                          label: 'Location',
                          value: issue.location,
                          iconColor: const Color(0xFFFF3B30),
                        ),
                        _divider(),
                        _infoRow(
                          icon: Icons.schedule_rounded,
                          label: 'Reported',
                          value: DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(issue.createdAt.toLocal()),
                          iconColor: const Color(0xFF5856D6),
                        ),
                        if (issue.category != null) ...[
                          _divider(),
                          _infoRow(
                            icon: Icons.category_rounded,
                            label: 'Category',
                            value: issue.category!,
                            iconColor: const Color(0xFF5856D6),
                          ),
                        ],
                        if (issue.priority != null) ...[
                          _divider(),
                          _infoRow(
                            icon: Icons.flag_rounded,
                            label: 'Priority',
                            value: issue.priority!,
                            iconColor: _priorityColor(issue.priority),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // -----------------------------------------------
                  // Description
                  // -----------------------------------------------
                  _sectionTitle('Description'),
                  _textSection(
                    'Reported Issue',
                    issue.description,
                    icon: Icons.description_outlined,
                  ),

                  // -----------------------------------------------
                  // AI Analysis
                  // -----------------------------------------------
                  if (issue.aiSummary != null) ...[
                    const SizedBox(height: 22),
                    _sectionTitle('AI Analysis'),
                    _textSection(
                      'AI Summary',
                      issue.aiSummary!,
                      icon: Icons.auto_awesome_rounded,
                    ),
                  ],

                  // -----------------------------------------------
                  // Before photo
                  // -----------------------------------------------
                  if (issue.beforeImageUrl != null) ...[
                    const SizedBox(height: 22),
                    _sectionTitle('Before Photo'),
                    _imageCard(issue.beforeImageUrl!, withError: true),
                  ],

                  // -----------------------------------------------
                  // After photo
                  // -----------------------------------------------
                  if (issue.afterImageUrl != null) ...[
                    const SizedBox(height: 22),
                    _sectionTitle('After Photo'),
                    _imageCard(issue.afterImageUrl!, withError: true),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}