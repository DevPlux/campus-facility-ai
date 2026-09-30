import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/assignment_provider.dart';

class CompleteTaskScreen extends StatefulWidget {
  final int assignmentId;

  const CompleteTaskScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  State<CompleteTaskScreen> createState() =>
      _CompleteTaskScreenState();
}

class _CompleteTaskScreenState
    extends State<CompleteTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  XFile? _afterImage;

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _afterImage = image;
      });
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading:
                    const Icon(Icons.camera_alt_outlined),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                ),
                title: const Text(
                  'Choose from Gallery',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _completeTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_afterImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add an after photo.',
          ),
        ),
      );
      return;
    }

    final provider =
        context.read<AssignmentProvider>();

    final success = await provider.completeTask(
      assignmentId: widget.assignmentId,
      completionNote: _noteController.text.trim(),
      afterImage: _afterImage!,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Task completed successfully.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Unable to complete task.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<AssignmentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Completion Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _noteController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Completion Note',
                  alignLabelWithHint: true,
                  hintText:
                      'Describe the work completed...',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter a completion note';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : _showImageOptions,
                icon:
                    const Icon(Icons.add_a_photo_outlined),
                label: Text(
                  _afterImage == null
                      ? 'Add After Photo'
                      : 'Photo Selected ✓',
                ),
              ),

              if (_afterImage != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),
                  child: Image.file(
                    File(_afterImage!.path),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          setState(() {
                            _afterImage = null;
                          });
                        },
                  icon:
                      const Icon(Icons.delete_outline),
                  label:
                      const Text('Remove Photo'),
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : _completeTask,
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  provider.isLoading
                      ? 'Completing...'
                      : 'Mark as Completed',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}