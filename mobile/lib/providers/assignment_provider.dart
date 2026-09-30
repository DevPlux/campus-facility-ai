import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/assignment.dart';
import '../services/assignment_service.dart';

class AssignmentProvider extends ChangeNotifier {
  final AssignmentService _assignmentService =
      AssignmentService();

  List<Assignment> _assignments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Assignment> get assignments => _assignments;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> loadMyTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _assignments =
          await _assignmentService.getMyTasks();
    } catch (_) {
      _errorMessage =
          'Unable to load assigned tasks.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startTask(int assignmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _assignmentService.startTask(
        assignmentId,
      );

      await loadMyTasks();

      return true;
    } catch (_) {
      _errorMessage = 'Unable to start this task.';
      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> completeTask({
    required int assignmentId,
    required String completionNote,
    required XFile afterImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _assignmentService.completeTask(
        assignmentId: assignmentId,
        completionNote: completionNote,
        afterImage: afterImage,
      );

      await loadMyTasks();

      return true;
    } catch (_) {
      _errorMessage =
          'Unable to complete this task.';
      _isLoading = false;
      notifyListeners();

      return false;
    }
  }
}