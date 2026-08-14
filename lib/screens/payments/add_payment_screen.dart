import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedRegistrationId;
  String? _selectedStudentName;
  String? _selectedCourseName;
  String? _selectedCourseCode;
  num _amountPaid = 0;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  String _paymentMethod = 'ABA / Bank Transfer';
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRegistrationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an active enrollment')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final docRef = FirebaseFirestore.instance.collection('payments').doc();

      // 1. Create Payment Receipt in 'payments'
      await docRef.set({
        'paymentId': docRef.id,
        'registrationId': _selectedRegistrationId,
        'studentName': _selectedStudentName,
        'courseName': _selectedCourseName,
        'courseCode': _selectedCourseCode,
        'amount': num.tryParse(_amountController.text.trim()) ?? _amountPaid,
        'paymentMethod': _paymentMethod,
        'referenceNo': _referenceController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Automatically update 'registrations' paymentStatus to 'Paid'
      await FirebaseFirestore.instance
          .collection('registrations')
          .doc(_selectedRegistrationId)
          .update({'paymentStatus': 'Paid'});

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Payment processed & receipt recorded!'),
          backgroundColor: Color(0xFF2563EB),
          behavior: SnackBarBehavior.floating,
        ),
      );
      nav.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error processing payment: $e'),
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
          'Process Tuition Payment',
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
                'Payment Receipt Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select a student enrollment and record tuition payment',
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
                    // Select Enrollment Dropdown
                    const Text(
                      'Select Student Enrollment *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('registrations')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const LinearProgressIndicator();
                        }
                        final docs = snapshot.data!.docs;
                        if (docs.isEmpty) {
                          return const Text(
                            'No registration records found. Please create a registration first.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: _selectedRegistrationId,
                          hint: const Text('Choose a student registration...'),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            prefixIcon: const Icon(
                              Icons.assignment_ind_rounded,
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
                          ),
                          items: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final sName = data['studentName'] ?? 'Unknown';
                            final cName = data['courseName'] ?? 'Course';
                            final price = data['price'] ?? 0;
                            final pStatus = data['paymentStatus'] ?? 'Pending';
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(
                                '$sName - $cName (\$$price) [$pStatus]',
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              final doc = docs.firstWhere(
                                (d) => d.id == newValue,
                              );
                              final data = doc.data() as Map<String, dynamic>;
                              setState(() {
                                _selectedRegistrationId = newValue;
                                _selectedStudentName =
                                    data['studentName'] ?? 'Unknown';
                                _selectedCourseName =
                                    data['courseName'] ?? 'Course';
                                _selectedCourseCode = data['courseCode'] ?? '';
                                _amountPaid = data['price'] ?? 0;
                                _amountController.text = _amountPaid.toString();
                              });
                            }
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Amount Paid Input
                    const Text(
                      'Amount Paid (\$) *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter payment amount';
                        }
                        if (num.tryParse(val.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(
                          Icons.attach_money_rounded,
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
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Payment Method Selector
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(
                          Icons.credit_card_rounded,
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
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ABA / Bank Transfer',
                          child: Text('ABA / Bank Transfer'),
                        ),
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(
                          value: 'Credit Card',
                          child: Text('Credit Card'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _paymentMethod = val);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Reference / Receipt No
                    const Text(
                      'Transaction Ref / Receipt No. (Optional)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _referenceController,
                      decoration: InputDecoration(
                        hintText: 'e.g. ABA-TXN-984210',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(
                          Icons.receipt_long_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
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
                  onPressed: _isSaving ? null : _savePayment,
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
                    _isSaving ? 'Processing...' : 'Confirm & Save Receipt',
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
