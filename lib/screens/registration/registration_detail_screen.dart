import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegistrationDetailScreen extends StatefulWidget {
  final String registrationId;
  final Map<String, dynamic> registrationData;

  const RegistrationDetailScreen({
    super.key,
    required this.registrationId,
    required this.registrationData,
  });

  @override
  State<RegistrationDetailScreen> createState() =>
      _RegistrationDetailScreenState();
}

class _RegistrationDetailScreenState extends State<RegistrationDetailScreen> {
  Future<void> _updatePaymentStatus(String currentStatus) async {
    String selectedStatus = currentStatus;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Update Payment Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedStatus = val);
                  }
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await FirebaseFirestore.instance
                      .collection('registrations')
                      .doc(widget.registrationId)
                      .update({'paymentStatus': selectedStatus});

                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Payment status updated to "$selectedStatus"',
                      ),
                      backgroundColor: const Color(0xFF2563EB),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error updating status: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRegistration(String studentName) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Registration',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete the enrollment record for "$studentName"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(dialogContext);
                final pageNav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                try {
                  await FirebaseFirestore.instance
                      .collection('registrations')
                      .doc(widget.registrationId)
                      .delete();

                  nav.pop();
                  pageNav.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Registration deleted successfully.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error deleting registration: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Enrollment Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('registrations')
            .doc(widget.registrationId)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.hasData && snapshot.data!.data() != null
              ? snapshot.data!.data() as Map<String, dynamic>
              : widget.registrationData;

          final studentName = data['studentName'] ?? 'Unknown Student';
          final courseName = data['courseName'] ?? 'Unknown Course';
          final courseCode = data['courseCode'] ?? 'NO-CODE';
          final price = data['price'] ?? 0;
          final status = data['status'] ?? 'Active';
          final paymentStatus = data['paymentStatus'] ?? 'Pending';
          final notes = data['notes'] ?? '';

          String formattedDate = 'N/A';
          if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
            final date = (data['createdAt'] as Timestamp).toDate();
            formattedDate = '${date.day}/${date.month}/${date.year}';
          }

          final initialLetter = studentName.isNotEmpty
              ? studentName[0].toUpperCase()
              : 'R';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Gradient Header
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(50),
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.white,
                          child: Text(
                            initialLetter,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enrolled in $courseName',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withAlpha(220),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Code: $courseCode',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'Active'
                                  ? const Color(0xFFDCFCE7)
                                  : status == 'Completed'
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: status == 'Active'
                                    ? const Color(0xFF166534)
                                    : status == 'Completed'
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF991B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Categorized Detail Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildSectionCard(
                        title: 'Enrollment Info',
                        items: [
                          _buildInfoRow(
                            icon: Icons.person_rounded,
                            label: 'Student Name',
                            value: studentName,
                          ),
                          _buildInfoRow(
                            icon: Icons.school_rounded,
                            label: 'Course Name',
                            value: '$courseName ($courseCode)',
                          ),
                          _buildInfoRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Enrollment Date',
                            value: formattedDate,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: 'Payment & Tuition',
                        items: [
                          _buildInfoRow(
                            icon: Icons.attach_money_rounded,
                            label: 'Course Fee',
                            value: '\$$price',
                          ),
                          _buildInfoRow(
                            icon: Icons.payment_rounded,
                            label: 'Payment Status',
                            value: paymentStatus,
                          ),
                          if (notes.toString().isNotEmpty)
                            _buildInfoRow(
                              icon: Icons.notes_rounded,
                              label: 'Remarks',
                              value: notes.toString(),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => _updatePaymentStatus(paymentStatus),
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text(
                            'Update Payment Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
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

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteRegistration(studentName),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: 18,
                          ),
                          label: const Text(
                            'Delete Registration',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
