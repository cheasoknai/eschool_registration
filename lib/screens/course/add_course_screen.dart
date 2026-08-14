import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _level;
  String? _studyTime;

  bool _isLoading = false;

  // todo: colors
  static const _primaryColor = Color(0xFF2563EB);
  static const _bgColor = Color(0xFFF8FAFC);
  static const _textColor = Color(0xFF0F172A);
  static const _labelColor = Color(0xFF334155);
  static const _subtextColor = Color(0xFF64748B);
  static const _borderColor = Color(0xFFE2E8F0);

  // todo: coure levels list
  final List<String> _levelList = const [
    'Beginner',
    'Elementary',
    'Pre-Intermediate',
    'Intermediate',
    'Upper-Intermediate',
    'Advanced',
  ];

  // todo: study time list
  final List<String> _studyTimeList = const [
    'Morning (7:00 AM - 11:00 AM)',
    'Afternoon (1:00 PM - 5:00 PM)',
    'Evening (5:30 PM - 8:30 PM)',
  ];

  // dispose
  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _teacherController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // CHECK COURSE CODE
  Future<bool> _isCourseCodeExists(String code) async {
    final query = await FirebaseFirestore.instance
        .collection('courses')
        .where('code', isEqualTo: code)
        .get();

    return query.docs.isNotEmpty;
  }

  // SAVE COURSE
  Future<void> _saveCourse() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_level == null) {
      _showMessage('Please select course level.');
      return;
    }
    if (_studyTime == null) {
      _showMessage('Please select study time.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final courseCode = _courseCodeController.text.trim();

      // Check duplicate course code
      final exists = await _isCourseCodeExists(courseCode);

      if (exists) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        _showMessage(
          'Course Code "$courseCode" already exists! '
          'Please use a unique code.',
        );
        return;
      }

      final price = double.tryParse(_priceController.text.trim());

      if (price == null) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        _showMessage('Please enter a valid price.');
        return;
      }

      await FirebaseFirestore.instance.collection('courses').add({
        'code': courseCode,
        'name': _courseNameController.text.trim(),
        'teacher': _teacherController.text.trim(),
        'level': _level,
        'studyTime': _studyTime,
        'price': price,
        'duration': _durationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Course added successfully.');

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Failed to add course: ${e.toString()}');
    }
  }

  // snackbar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,

      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add New Course',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Course Registration',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Enter course details to create a new course.',
                  style: TextStyle(fontSize: 14, color: _subtextColor),
                ),

                const SizedBox(height: 24),

                //  todo: course code
                _buildLabel('Course Code'),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _courseCodeController,
                  textInputAction: TextInputAction.next,

                  textCapitalization: TextCapitalization.characters,

                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter course code';
                    }

                    if (v.trim().length < 3) {
                      return 'Course code must be at least 3 characters';
                    }

                    return null;
                  },

                  decoration: _inputDecoration(
                    hint: 'e.g., ENG01',
                    icon: Icons.badge_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // todo: course name
                _buildLabel('Course Name'),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _courseNameController,
                  textInputAction: TextInputAction.next,

                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter course name';
                    }

                    if (v.trim().length < 2) {
                      return 'Enter a valid course name';
                    }

                    return null;
                  },

                  decoration: _inputDecoration(
                    hint: 'e.g., General English',
                    icon: Icons.school_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // todo: teacher name
                _buildLabel('Teacher'),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _teacherController,
                  textInputAction: TextInputAction.next,

                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter teacher name';
                    }

                    if (v.trim().length < 2) {
                      return 'Enter a valid teacher name';
                    }

                    return null;
                  },

                  decoration: _inputDecoration(
                    hint: 'Enter teacher name',
                    icon: Icons.person_outline_rounded,
                  ),
                ),

                const SizedBox(height: 18),

                // todo: course level
                _buildLabel('Course Level'),

                const SizedBox(height: 6),

                DropdownButtonFormField<String>(
                  value: _level,

                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _subtextColor,
                  ),

                  decoration: _inputDecoration(
                    hint: 'Select course level',
                    icon: Icons.trending_up_rounded,
                  ),

                  items: _levelList
                      .map(
                        (level) =>
                            DropdownMenuItem(value: level, child: Text(level)),
                      )
                      .toList(),

                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _level = value;
                          });
                        },
                ),

                const SizedBox(height: 18),

                // todo: study time
                _buildLabel('Study Time'),

                const SizedBox(height: 6),

                DropdownButtonFormField<String>(
                  value: _studyTime,

                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _subtextColor,
                  ),

                  decoration: _inputDecoration(
                    hint: 'Select study time',
                    icon: Icons.schedule_outlined,
                  ),

                  items: _studyTimeList
                      .map(
                        (time) =>
                            DropdownMenuItem(value: time, child: Text(time)),
                      )
                      .toList(),

                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _studyTime = value;
                          });
                        },
                ),

                const SizedBox(height: 18),

                // todo: course price
                _buildLabel('Course Price'),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _priceController,

                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  textInputAction: TextInputAction.next,

                  validator: (v) {
                    final price = double.tryParse(v?.trim() ?? '');

                    if (v == null || v.trim().isEmpty) {
                      return 'Enter course price';
                    }

                    if (price == null || price < 0) {
                      return 'Enter a valid price';
                    }

                    return null;
                  },

                  decoration: _inputDecoration(
                    hint: 'e.g., 50.00',
                    icon: Icons.attach_money_rounded,
                  ),
                ),

                const SizedBox(height: 18),

                // todo: duration (month)
                _buildLabel('Duration'),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _durationController,
                  textInputAction: TextInputAction.next,

                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter course duration';
                    }

                    return null;
                  },

                  decoration: _inputDecoration(
                    hint: 'e.g., 3 months',
                    icon: Icons.timelapse_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // todo: description
                _buildLabel('Description'),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _descriptionController,

                  maxLines: 3,

                  textInputAction: TextInputAction.newline,

                  decoration: _inputDecoration(
                    hint: 'Enter course description',
                    icon: Icons.description_outlined,
                  ),
                ),

                const SizedBox(height: 32),

                // todo: save course button
                SizedBox(
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveCourse,

                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,

                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 20,
                          ),

                    label: Text(
                      _isLoading ? 'Saving Course...' : 'Save Course',

                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,

                      disabledBackgroundColor: const Color(0xFF93B4F5),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // todo: label
  Widget _buildLabel(String text) {
    return Text(
      text,

      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _labelColor,
      ),
    );
  }

  // todo: input decoraton
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),

      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),

      filled: true,

      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}
