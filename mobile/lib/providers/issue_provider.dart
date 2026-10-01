import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/issue.dart';
import '../services/issue_service.dart';

class IssueProvider extends ChangeNotifier {
  final IssueService _issueService = IssueService();

  List<Issue> _issues = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Issue> get issues => _issues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMyIssues() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _issues = await _issueService.getMyIssues();
    } catch (_) {
      _errorMessage = 'Unable to load your issues.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createIssue({
    required String title,
    required String description,
    required String location,
    XFile? beforeImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final issue = await _issueService.createIssue(
        title: title,
        description: description,
        location: location,
        beforeImage: beforeImage,
      );

      _issues.insert(0, issue);

      return true;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      _errorMessage =
          'HTTP STATUS: ${statusCode ?? 'NO STATUS'}\n\n'
          'SERVER RESPONSE:\n'
          '${responseData ?? e.message ?? 'No response received'}';

      return false;
    } catch (e) {
      _errorMessage =
          'APP ERROR:\n'
          '$e';

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}