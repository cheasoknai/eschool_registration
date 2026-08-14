import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditStudentScreen extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> studentData;

  const EditStudentScreen({
    super.key,
    required this.studentId,
    required this.studentData,
  });

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _studentIdController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  late String _selectedGender;
  late String _selectedClass;
  late String _selectedStudyTime;
  DateTime? _selectedDob;

  bool _isLoading = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _classOptions = [
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
  final List<String> _studyTimeOptions = [
    'Morning',
    'Afternoon',
    'Evening',
    'Full Time',
  ];

  @override
  void initState() {
    super.initState();
    _studentIdController = TextEditingController(
      text: (widget.studentData['studentId'] ?? widget.studentData['id'] ?? '')
          .toString(),
    );
    _nameController = TextEditingController(
      text: widget.studentData['fullName'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.studentData['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.studentData['phone'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.studentData['address'] ?? '',
    );

    _selectedGender = widget.studentData['gender'] ?? 'Male';
    _selectedClass =
        widget.studentData['className'] ??
        widget.studentData['studentClass'] ??
        widget.studentData['class'] ??
        'Class 1A';
    _selectedStudyTime = widget.studentData['studyTime'] ?? 'Morning';

    // Parse existing Date of Birth
    final dob = widget.studentData['dateOfBirth'];
    if (dob is Timestamp) {
      _selectedDob = dob.toDate();
    } else if (dob is String) {
      _selectedDob = DateTime.tryParse(dob);
    }

    if (!_genderOptions.contains(_selectedGender)) _selectedGender = 'Male';
    if (!_classOptions.contains(_selectedClass)) _selectedClass = 'Class 1A';
    if (!_studyTimeOptions.contains(_selectedStudyTime)) {
      _selectedStudyTime = 'Morning';
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2005, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() => _selectedDob = pickedDate);
    }
  }

  String _formatDobText() {
    if (_selectedDob == null) return 'Select Date of Birth';
    return "${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}";
  }

  Future<void> _updateStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .update({
            'studentId': _studentIdController.text.trim(),
            'fullName': _nameController.text.trim(),
            'gender': _selectedGender,
            'dateOfBirth': _selectedDob != null
                ? Timestamp.fromDate(_selectedDob!)
                : null,
            'className': _selectedClass,
            'studentClass': _selectedClass,
            'studyTime': _selectedStudyTime,
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating student: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Edit Student',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Student ID
              _buildLabel('Student ID'),
              TextFormField(
                controller: _studentIdController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('e.g., 101'),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter Student ID'
                    : null,
              ),
              const SizedBox(height: 16),

              // 2. Full Name
              _buildLabel('Full Name'),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Full Name'),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter full name'
                    : null,
              ),
              const SizedBox(height: 16),

              // 3. Gender
              _buildLabel('Gender'),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: _buildInputDecoration('Select Gender'),
                items: _genderOptions.map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGender = val);
                },
              ),
              const SizedBox(height: 16),

              // 4. Date of Birth
              _buildLabel('Date of Birth'),
              InkWell(
                onTap: _pickDateOfBirth,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDobText(),
                        style: TextStyle(
                          color: _selectedDob == null
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF0F172A),
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Assigned Class
              _buildLabel('Assigned Class'),
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: _buildInputDecoration('Select Class'),
                items: _classOptions.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedClass = val);
                },
              ),
              const SizedBox(height: 16),

              // 6. Study Time
              _buildLabel('Study Time'),
              DropdownButtonFormField<String>(
                value: _selectedStudyTime,
                decoration: _buildInputDecoration('Select Study Time'),
                items: _studyTimeOptions.map((st) {
                  return DropdownMenuItem(value: st, child: Text(st));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStudyTime = val);
                },
              ),
              const SizedBox(height: 16),

              // 7. Email
              _buildLabel('Email'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration('Email'),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter email address'
                    : null,
              ),
              const SizedBox(height: 16),

              // 8. Phone Number
              _buildLabel('Phone Number'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration('Phone Number'),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter phone number'
                    : null,
              ),
              const SizedBox(height: 16),

              // 9. Address
              _buildLabel('Address'),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: _buildInputDecoration('Address'),
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Student',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}
