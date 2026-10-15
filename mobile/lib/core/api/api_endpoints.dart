
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://campus-facility-ai.onrender.com/api',
  );

  // Authentication
  static const String login = '/auth/login';

  // Issues
  static const String createIssue = '/issues';
  static const String myIssues = '/issues/my';
  static const String issues = '/issues';

  static String issueById(int id) => '/issues/$id';

  // Technician Tasks
  static const String myTasks =
      '/technicians/my-tasks';

  // Assignments
  static String startAssignment(int id) =>
      '/assignments/$id/start';

  static String completeAssignment(int id) =>
      '/assignments/$id/complete';
}
