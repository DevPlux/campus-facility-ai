class AssignmentIssue {
  final int id;
  final String title;
  final String description;
  final String location;
  final String? category;
  final String? priority;
  final String? requiredSkill;
  final String? aiSummary;
  final String status;
  final String? beforeImageUrl;
  final String? afterImageUrl;

  const AssignmentIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.category,
    this.priority,
    this.requiredSkill,
    this.aiSummary,
    required this.status,
    this.beforeImageUrl,
    this.afterImageUrl,
  });
}

class Assignment {
  final int id;
  final int issueId;
  final String status;
  final String? aiReason;
  final AssignmentIssue? issue;
  final DateTime? createdAt;
  final DateTime? approvedAt;

  const Assignment({
    required this.id,
    required this.issueId,
    required this.status,
    this.aiReason,
    this.issue,
    this.createdAt,
    this.approvedAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    final issueId = json['issueId'] as int;

    return Assignment(
      id: json['assignmentId'] as int,
      issueId: issueId,

      // Backend returns AssignmentStatus
      status: json['assignmentStatus']?.toString() ?? 'UNKNOWN',

      // Backend returns RecommendationReason
      aiReason: json['recommendationReason']?.toString(),

      // Backend response is FLAT, so construct the issue
      // object ourselves for the existing UI.
      issue: AssignmentIssue(
        id: issueId,
        title: json['title']?.toString() ?? 'Facility Issue',
        description: json['description']?.toString() ?? '',
        location: json['location']?.toString() ?? '',
        category: json['category']?.toString(),
        priority: json['priority']?.toString(),
        requiredSkill: json['requiredSkill']?.toString(),
        aiSummary: json['aiSummary']?.toString(),
        status: json['issueStatus']?.toString() ?? 'UNKNOWN',
        beforeImageUrl: json['beforeImageUrl']?.toString(),
        afterImageUrl: json['afterImageUrl']?.toString(),
      ),

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,

      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'].toString())
          : null,
    );
  }

  Assignment copyWith({
    String? status,
  }) {
    return Assignment(
      id: id,
      issueId: issueId,
      status: status ?? this.status,
      aiReason: aiReason,
      issue: issue,
      createdAt: createdAt,
      approvedAt: approvedAt,
    );
  }
}