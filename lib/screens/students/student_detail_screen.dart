import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eschool_registration/screens/students/edit_student_screen.dart';
import 'package:flutter/material.dart';

class StudentDetailScreen extends StatelessWidget {
  final String studentId;
  final Map<String, dynamic> studentData;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
    required this.studentData,
  });

  String _formatDate(dynamic dob) {
    if (dob == null) return 'Not specified';
    DateTime date;
    if (dob is Timestamp) {
      date = dob.toDate();
    } else if (dob is String) {
      final parsed = DateTime.tryParse(dob);
      if (parsed != null) {
        date = parsed;
      } else {
        return dob;
      }
    } else {
      return 'Not specified';
    }
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .snapshots(),
      builder: (context, snapshot) {
        final Map<String, dynamic> data =
            snapshot.hasData && snapshot.data!.data() != null
            ? snapshot.data!.data() as Map<String, dynamic>
            : studentData;

        final customId = data['studentId'] as String? ?? 'N/A';
        final name = data['fullName'] as String? ?? 'No name';
        final gender = data['gender'] as String? ?? 'Not specified';
        final dob = _formatDate(data['dateOfBirth']);
        final studentClass =
            (data['className'] ?? data['studentClass']) as String? ??
            'Not assigned';
        final studyTime = data['studyTime'] as String? ?? 'Not specified';
        final email = data['email'] as String? ?? 'No email';
        final phone = data['phone'] as String? ?? 'No phone';
        final address = data['address'] as String? ?? 'No address';

        final initial = name.trim().isNotEmpty
            ? name.trim()[0].toUpperCase()
            : '?';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text(
              'Student Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // HEADER AVATAR SECTION
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 110, 24, 32),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withAlpha(64),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.white,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(45),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.badge_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ID: $customId',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(45),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.school_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      studentClass,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Active Student',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // DETAILS CONTENT AREA
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QUICK ACTIONS BAR
                      if (email != 'No email' || phone != 'No phone') ...[
                        Row(
                          children: [
                            if (email != 'No email')
                              Expanded(
                                child: _buildQuickActionButton(
                                  context: context,
                                  icon: Icons.email_rounded,
                                  label: 'Send Email',
                                  color: const Color(0xFF2563EB),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Emailing $email...'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            if (email != 'No email' && phone != 'No phone')
                              const SizedBox(width: 12),
                            if (phone != 'No phone')
                              Expanded(
                                child: _buildQuickActionButton(
                                  context: context,
                                  icon: Icons.phone_rounded,
                                  label: 'Call Phone',
                                  color: const Color(0xFF10B981),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Calling $phone...'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ACADEMIC INFORMATION SECTION
                      _buildSectionTitle('Academic Information'),
                      const SizedBox(height: 10),
                      _infoCard(
                        icon: Icons.school_outlined,
                        title: 'Enrolled Class',
                        value: studentClass,
                      ),
                      _infoCard(
                        icon: Icons.schedule_outlined,
                        title: 'Study Time',
                        value: studyTime,
                      ),
                      _infoCard(
                        icon: Icons.badge_outlined,
                        title: 'Student ID',
                        value: customId,
                      ),

                      const SizedBox(height: 16),

                      // PERSONAL INFORMATION SECTION
                      _buildSectionTitle('Personal Information'),
                      const SizedBox(height: 10),
                      _infoCard(
                        icon: Icons.person_outline_rounded,
                        title: 'Full Name',
                        value: name,
                      ),
                      _infoCard(
                        icon: Icons.wc_outlined,
                        title: 'Gender',
                        value: gender,
                      ),
                      _infoCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Date of Birth',
                        value: dob,
                      ),

                      const SizedBox(height: 16),

                      // CONTACT DETAILS SECTION
                      _buildSectionTitle('Contact Details'),
                      const SizedBox(height: 10),
                      _infoCard(
                        icon: Icons.email_outlined,
                        title: 'Email Address',
                        value: email,
                      ),
                      _infoCard(
                        icon: Icons.phone_outlined,
                        title: 'Phone Number',
                        value: phone,
                      ),
                      _infoCard(
                        icon: Icons.location_on_outlined,
                        title: 'Home Address',
                        value: address,
                      ),

                      const SizedBox(height: 24),

                      // EDIT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditStudentScreen(
                                  studentId: studentId,
                                  studentData: data,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text(
                            'Edit Student Profile',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // DELETE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteStudent(context),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text(
                            'Delete Student Record',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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

  Future<void> _deleteStudent(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Student'),
          content: const Text(
            'Are you sure you want to delete this student record? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .delete();

      navigator.pop();
      navigator.pop();

      messenger.showSnackBar(
        const SnackBar(content: Text('Student deleted successfully.')),
      );
    } catch (e) {
      navigator.pop();

      messenger.showSnackBar(
        SnackBar(content: Text('Failed to delete student: $e')),
      );
    }
  }
}
