import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/issue.dart';

class IssueService {
  Future<List<Issue>> getMyIssues() async {
    final response = await ApiClient.dio.get(
      ApiEndpoints.myIssues,
    );

    final List<dynamic> data = response.data;

    return data
        .map((json) => Issue.fromJson(json))
        .toList();
  }

  Future<Issue> getIssueById(int id) async {
    final response = await ApiClient.dio.get(
      ApiEndpoints.issueById(id),
    );

    return Issue.fromJson(response.data);
  }

  Future<Issue> createIssue({
    required String title,
    required String description,
    required String location,
    XFile? beforeImage,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'location': location,

      // ASP.NET CreateIssueRequestDto expects Image
      if (beforeImage != null)
        'image': await MultipartFile.fromFile(
          beforeImage.path,
          filename: beforeImage.name,
        ),
    });

    final response = await ApiClient.dio.post(
      ApiEndpoints.createIssue,
      data: formData,
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );

    return Issue.fromJson(response.data);
  }
}