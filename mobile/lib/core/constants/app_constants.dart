class AppConstants {
  AppConstants._();

  static const String appName = 'Campus Facility AI';

  // User Roles
  static const String roleReporter = 'REPORTER';
  static const String roleTechnician = 'TECHNICIAN';
  static const String roleManager = 'MANAGER';

  // Issue Statuses
  static const String statusOpen = 'OPEN';
  static const String statusAnalyzed = 'ANALYZED';
  static const String statusPendingApproval = 'PENDING_APPROVAL';
  static const String statusAssigned = 'ASSIGNED';
  static const String statusInProgress = 'IN_PROGRESS';
  static const String statusCompleted = 'COMPLETED';
  static const String statusRejected = 'REJECTED';

  // Issue Categories
  static const List<String> issueCategories = [
    'PLUMBING',
    'ELECTRICAL',
    'IT',
    'HVAC',
    'FURNITURE',
    'GENERAL',
  ];

  // Priorities
  static const String priorityLow = 'LOW';
  static const String priorityMedium = 'MEDIUM';
  static const String priorityHigh = 'HIGH';

  // Image Types
  static const String imageBefore = 'BEFORE';
  static const String imageAfter = 'AFTER';
}