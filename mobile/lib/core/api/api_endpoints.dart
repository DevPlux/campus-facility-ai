class ApiEndpoints {
  ApiEndpoints._();

  // We will replace this with the actual ASP.NET Core backend address later.
 static const String baseUrl = 'http://192.168.8.135:5066/api';

  // Authentication
  static const String login = '/auth/login';

  // Issues
  static const String createIssue = '/issues';
  static const String myIssues = '/issues/my';
  static const String issues = '/issues';

  static String issueById(int id) => '/issues/$id';

  // Technician Tasks
  static const String myTasks = '/technicians/my-tasks';

  // Assignments
  static String startAssignment(int id) => '/assignments/$id/start';

  static String completeAssignment(int id) =>
      '/assignments/$id/complete';
}