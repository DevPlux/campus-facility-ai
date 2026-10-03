import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/assignment.dart';

class AssignmentService {
  Future<List<Assignment>> getMyTasks() async {
    final response = await ApiClient.dio.get(
      ApiEndpoints.myTasks,
    );

    final List<dynamic> data = response.data;

    return data
        .map((json) => Assignment.fromJson(json))
        .toList();
  }

  Future<void> startTask(int assignmentId) async {
    await ApiClient.dio.patch(
      ApiEndpoints.startAssignment(assignmentId),
    );
  }

  Future<void> completeTask({
    required int assignmentId,
    required String completionNote,
    required XFile afterImage,
  }) async {
    final formData = FormData.fromMap({
      'completionNote': completionNote,

      // Backend expects the multipart field "Image"
      'image': await MultipartFile.fromFile(
        afterImage.path,
        filename: afterImage.name,
      ),
    });

    await ApiClient.dio.patch(
      ApiEndpoints.completeAssignment(assignmentId),
      data: formData,
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }
}