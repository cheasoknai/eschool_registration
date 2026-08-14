import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddRegistrationScreen extends StatefulWidget {
  const AddRegistrationScreen({super.key});

  @override
  State<AddRegistrationScreen> createState() => _AddRegistrationScreenState();
}

class _AddRegistrationScreenState extends State<AddRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedStudentId;
  String? _selectedStudentName;

  String? _selectedCourseId;
  String? _selectedCourseName;
  String? _selectedCourseCode;
  num _selectedCoursePrice = 0;

  String _status = 'Active';
  String _paymentStatus = 'Pending';
  final TextEditingController _notesController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a student')));
      return;
    }
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a course')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('registrations')
          .doc();
      await docRef.set({
        'registrationId': docRef.id,
        'studentId': _selectedStudentId,
        'studentName': _selectedStudentName,
        'courseId': _selectedCourseId,
        'courseName': _selectedCourseName,
        'courseCode': _selectedCourseCode,
        'price': _selectedCoursePrice,
        'status': _status,
        'paymentStatus': _paymentStatus,
        'notes': _notesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Student successfully enrolled!'),
          backgroundColor: Color(0xFF2563EB),
          behavior: SnackBarBehavior.floating,
        ),
      );
      nav.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error creating registration: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'New Course Enrollment',
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
              const Text(
                'Enrollment Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select a student and course to create a new registration record',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Selector Dropdown (Live from Firestore)
                    const Text(
                      'Select Student *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('students')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const LinearProgressIndicator();
                        }
                        final docs = snapshot.data!.docs;
                        if (docs.isEmpty) {
                          return const Text(
                            'No students found. Please add a student first.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: _selectedStudentId,
                          hint: const Text('Choose a student...'),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            prefixIcon: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF2563EB),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                          items: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = data['fullName'] ?? 'Unknown Student';
                            final customId =
                                data['studentId'] ?? data['id'] ?? doc.id;
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text('$name ($customId)'),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              final selectedDoc = docs.firstWhere(
                                (d) => d.id == newValue,
                              );
                              final data =
                                  selectedDoc.data() as Map<String, dynamic>;
                              setState(() {
                                _selectedStudentId = newValue;
                                _selectedStudentName =
                                    data['fullName'] ?? 'Unknown';
                              });
                            }
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Course Selector Dropdown (Live from Firestore)
                    const Text(
                      'Select Course *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('courses')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const LinearProgressIndicator();
                        }
                        final docs = snapshot.data!.docs;
                        if (docs.isEmpty) {
                          return const Text(
                            'No courses found. Please add a course first.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: _selectedCourseId,
                          hint: const Text('Choose a course...'),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            prefixIcon: const Icon(
                              Icons.school_rounded,
                              color: Color(0xFF2563EB),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                          items: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = data['name'] ?? 'Unknown Course';
                            final code = data['code'] ?? '';
                            final price = data['price'] ?? 0;
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text('$name [$code] - \$$price'),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              final selectedDoc = docs.firstWhere(
                                (d) => d.id == newValue,
                              );
                              final data =
                                  selectedDoc.data() as Map<String, dynamic>;
                              setState(() {
                                _selectedCourseId = newValue;
                                _selectedCourseName = data['name'] ?? 'Unknown';
                                _selectedCourseCode = data['code'] ?? '';
                                _selectedCoursePrice = data['price'] ?? 0;
                              });
                            }
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Status & Payment Status Dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _status,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Active',
                                    child: Text('Active'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Completed',
                                    child: Text('Completed'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Cancelled',
                                    child: Text('Cancelled'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _status = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Payment Status',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _paymentStatus,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Paid',
                                    child: Text('Paid'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Pending',
                                    child: Text('Pending'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Unpaid',
                                    child: Text('Unpaid'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _paymentStatus = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Tuition Fee Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.payments_rounded,
                                color: Color(0xFF2563EB),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tuition Fee:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$$_selectedCoursePrice',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveRegistration,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(
                    _isSaving ? 'Processing...' : 'Confirm Enrollment',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
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
    );
  }
}
