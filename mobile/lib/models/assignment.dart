import 'issue.dart';

class Assignment {
  final int id;
  final int issueId;
  final int technicianId;
  final String status;
  final String? aiReason;
  final Issue? issue;

  const Assignment({
    required this.id,
    required this.issueId,
    required this.technicianId,
    required this.status,
    this.aiReason,
    this.issue,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      issueId: json['issueId'],
      technicianId: json['technicianId'],
      status: json['status'],
      aiReason: json['aiReason'],
      issue: json['issue'] != null
          ? Issue.fromJson(json['issue'])
          : null,
    );
  }
}