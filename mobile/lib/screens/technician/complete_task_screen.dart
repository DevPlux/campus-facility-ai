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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                // grab handle
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Add After Photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2433),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose a source',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 16),
                _sheetTile(
                  icon: Icons.camera_alt_rounded,
                  title: 'Take Photo',
                  subtitle: 'Use your camera',
                  color: const Color(0xFF0A84FF),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _sheetTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from Gallery',
                  subtitle: 'Pick an existing photo',
                  color: const Color(0xFF5856D6),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2433),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFC7C7CC),
                ),
              ],
            ),
          ),
        ),
      ),
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

  // ---------------------------------------------------------------------------
  // UI helpers (visual only)
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8E8E93),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF34C759),
            Color(0xFF28A745),
            Color(0xFF1E7A34),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3334C759),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: Colors.white.withOpacity(0.18),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.checklist_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Final Step',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          const Text(
            'COMPLETE TASK',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 11.5,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Completion Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Add a note and an after photo to close this task.',
            style: TextStyle(
              color: Color(0xE6FFFFFF),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _noteDecoration() {
    const radius = BorderRadius.all(Radius.circular(16));

    return InputDecoration(
      labelText: 'Completion Note',
      alignLabelWithHint: true,
      hintText: 'Describe the work completed...',
      hintStyle: const TextStyle(
        color: Color(0xFFA0AAB8),
        fontSize: 13.5,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF7A8797),
        fontSize: 14,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF34C759),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: const Color(0xFFF6F8FB),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Color(0xFF34C759), width: 1.6),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Color(0xFFE53935)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Color(0xFFE53935), width: 1.6),
      ),
    );
  }

  Widget _photoPickerTile(bool loading) {
    final hasPhoto = _afterImage != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: loading ? null : _showImageOptions,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: hasPhoto
                ? const Color(0xFF34C759).withOpacity(0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasPhoto
                  ? const Color(0xFF34C759).withOpacity(0.35)
                  : const Color(0xFFE2E8F0),
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: hasPhoto
                        ? const [Color(0xFF34C759), Color(0xFF28A745)]
                        : const [Color(0xFF0A84FF), Color(0xFF0066CC)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (hasPhoto
                              ? const Color(0xFF34C759)
                              : const Color(0xFF0A84FF))
                          .withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  hasPhoto
                      ? Icons.check_rounded
                      : Icons.add_a_photo_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasPhoto ? 'Photo Added' : 'Add After Photo',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2433),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasPhoto
                          ? 'Tap to replace the current photo'
                          : 'Required to complete the task',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFC7C7CC),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _submitButton(bool loading) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: loading
                ? const [Color(0xFF9EE0B0), Color(0xFF9EE0B0)]
                : const [Color(0xFF34C759), Color(0xFF28A745)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: loading
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x4D34C759),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
        ),
        child: ElevatedButton.icon(
          onPressed: loading ? null : _completeTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.check_circle_rounded, size: 20),
          label: Text(
            loading ? 'Completing...' : 'Mark as Completed',
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<AssignmentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // -----------------------------------------------
                    // Completion note
                    // -----------------------------------------------
                    _sectionTitle('Work Summary'),
                    _card(
                      child: TextFormField(
                        controller: _noteController,
                        maxLines: 5,
                        decoration: _noteDecoration(),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter a completion note';
                          }

                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    // -----------------------------------------------
                    // After photo
                    // -----------------------------------------------
                    _sectionTitle('After Photo'),
                    _photoPickerTile(provider.isLoading),

                    if (_afterImage != null) ...[
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x18000000),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Image.file(
                                File(_afterImage!.path),
                                height: 230,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              // subtle top gradient for contrast
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.25),
                                        Colors.transparent,
                                        Colors.transparent,
                                      ],
                                      stops: const [0, 0.35, 1],
                                    ),
                                  ),
                                ),
                              ),
                              // preview badge
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.image_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Preview',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // remove button
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Material(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: provider.isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _afterImage = null;
                                            });
                                          },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // -----------------------------------------------
                    // Submit
                    // -----------------------------------------------
                    _submitButton(provider.isLoading),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}