import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _customIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _gender;
  String? _studentClass;
  String? _studyTime;
  DateTime? _selectedDob;
  bool _isLoading = false;

  static const _primaryColor = Color(0xFF2563EB);
  static const _bgColor = Color(0xFFF8FAFC);
  static const _textColor = Color(0xFF0F172A);
  static const _labelColor = Color(0xFF334155);
  static const _subtextColor = Color(0xFF64748B);
  static const _borderColor = Color(0xFFE2E8F0);

  final List<String> _classList = const [
    'Class 1-A',
    'Class 1-B',
    'Class 2-A',
    'Class 2-B',
    'Class 3-A',
    'Class 3-B',
    'Class 4-A',
    'Class 4-B',
    'Class 5-A',
    'Class 5-B',
    'Class 6-A',
    'Class 6-B',
    'Class 7-A',
    'Class 7-B',
    'Class 8-A',
    'Class 8-B',
    'Class 9-A',
    'Class 9-B',
    'Class 10-A',
    'Class 11-A',
    'Class 11-A',
    'Class 12-A',
    'Class 12-B',
  ];

  final List<String> _studyTimeList = const [
    'Morning (7:00 AM - 11:00 AM)',
    'Afternoon (1:00 PM - 5:00 PM)',
    'Evening (5:30 PM - 8:30 PM)',
  ];

  @override
  void dispose() {
    _customIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 15, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: _textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  // Check if Student ID already exists in Firestore
  Future<bool> _isStudentIdExists(String customId) async {
    final query = await FirebaseFirestore.instance
        .collection('students')
        .where('studentId', isEqualTo: customId)
        .get();

    return query.docs.isNotEmpty;
  }

  Future<void> _saveStudent() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_gender == null) {
      _showMessage('Please select gender.');
      return;
    }

    if (_selectedDob == null) {
      _showMessage('Please select date of birth.');
      return;
    }

    if (_studentClass == null) {
      _showMessage('Please select a class.');
      return;
    }

    if (_studyTime == null) {
      _showMessage('Please select study time.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final customId = _customIdController.text.trim();

      // Check duplicate ID
      final exists = await _isStudentIdExists(customId);
      if (exists) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showMessage(
          'Student ID "$customId" already exists! Please use a unique ID.',
        );
        return;
      }

      await FirebaseFirestore.instance.collection('students').add({
        'studentId': customId,
        'fullName': _nameController.text.trim(),
        'gender': _gender,
        'dateOfBirth': Timestamp.fromDate(_selectedDob!),
        'className': _studentClass, // Aligned with student list filter
        'studyTime': _studyTime,
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() => _isLoading = false);
      _showMessage('Student added successfully.');

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Failed to add student: ${e.toString()}');
    }
  }

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
          'Add New Student',
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
                  'Student Registration',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter student details to create a new profile.',
                  style: TextStyle(fontSize: 14, color: _subtextColor),
                ),
                const SizedBox(height: 24),

                // 1. Student ID
                _buildLabel('Student ID'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _customIdController,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter student ID'
                      : null,
                  decoration: _inputDecoration(
                    hint: 'e.g., ST001',
                    icon: Icons.badge_outlined,
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Full Name
                _buildLabel('Full Name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Enter a valid full name'
                      : null,
                  decoration: _inputDecoration(
                    hint: 'Enter full name',
                    icon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Gender
                _buildLabel('Gender'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _gender,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF64748B),
                  ),
                  decoration: _inputDecoration(
                    hint: 'Select gender',
                    icon: Icons.people_outline_rounded,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (v) => setState(() => _gender = v),
                ),
                const SizedBox(height: 18),

                // 4. Date of Birth
                _buildLabel('Date of Birth'),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _isLoading ? null : _selectDateOfBirth,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      hint: 'Select Date of Birth',
                      icon: Icons.calendar_today_outlined,
                    ),
                    child: Text(
                      _selectedDob == null
                          ? 'Select Date of Birth'
                          : "${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}",
                      style: TextStyle(
                        fontSize: 15,
                        color: _selectedDob == null
                            ? const Color(0xFF94A3B8)
                            : _textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Class Selection
                _buildLabel('Class'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _studentClass,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF64748B),
                  ),
                  decoration: _inputDecoration(
                    hint: 'Select class',
                    icon: Icons.school_outlined,
                  ),
                  items: _classList
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: _isLoading
                      ? null
                      : (v) => setState(() => _studentClass = v),
                ),
                const SizedBox(height: 18),

                // 5. Study Time
                _buildLabel('Study Time'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _studyTime,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF64748B),
                  ),
                  decoration: _inputDecoration(
                    hint: 'Select study time',
                    icon: Icons.schedule_outlined,
                  ),
                  items: _studyTimeList
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: _isLoading
                      ? null
                      : (v) => setState(() => _studyTime = v),
                ),
                const SizedBox(height: 18),

                // 6. Email Address
                _buildLabel('Email Address'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final email = v?.trim() ?? '';
                    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    return regex.hasMatch(email)
                        ? null
                        : 'Enter a valid email address';
                  },
                  decoration: _inputDecoration(
                    hint: 'example@gmail.com',
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 18),

                // 7. Phone Number
                _buildLabel('Phone Number'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().length < 8)
                      ? 'Enter a valid phone number'
                      : null,
                  decoration: _inputDecoration(
                    hint: 'Enter phone number',
                    icon: Icons.phone_outlined,
                  ),
                ),
                const SizedBox(height: 18),

                // 8. Address
                _buildLabel('Address'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: _inputDecoration(
                    hint: 'Enter address',
                    icon: Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveStudent,
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
                      _isLoading ? 'Saving Student...' : 'Save Student',
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
