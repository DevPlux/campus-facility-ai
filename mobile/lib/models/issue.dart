class Issue {
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
  final DateTime createdAt;

  const Issue({
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
    required this.createdAt,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      category: json['category'],
      priority: json['priority'],
      requiredSkill: json['requiredSkill'],
      aiSummary: json['aiSummary'],
      status: json['status'],
      beforeImageUrl: json['beforeImageUrl'],
      afterImageUrl: json['afterImageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}