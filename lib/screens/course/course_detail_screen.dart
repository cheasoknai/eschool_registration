import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eschool_registration/screens/course/edit_course_screen.dart';
import 'package:flutter/material.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  final Map<String, dynamic> courseData;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.courseData,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .snapshots(),
      builder: (context, snapshot) {
        final Map<String, dynamic> data =
            snapshot.hasData && snapshot.data!.data() != null
            ? snapshot.data!.data() as Map<String, dynamic>
            : courseData;

        final name = data['name'] as String? ?? 'Unknown Course';
        final code = data['code'] as String? ?? 'No Code';
        final teacher = data['teacher'] as String? ?? 'No Teacher';
        final level = data['level'] as String? ?? 'Not specified';
        final studyTime = data['studyTime'] as String? ?? 'Not specified';
        final price = data['price'] ?? 0;
        final duration = data['duration'] as String? ?? 'No Duration';
        final description =
            data['description'] as String? ?? 'No description provided.';

        final initial = name.trim().isNotEmpty
            ? name.trim()[0].toUpperCase()
            : '?';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text(
              'Course Details',
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
                                      'Code: $code',
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
                                      Icons.trending_up_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      level,
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
                                      'Active Course',
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

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // todo: course overview section
                      _buildSectionTitle('Course Overview'),
                      const SizedBox(height: 10),
                      _infoCard(
                        icon: Icons.badge_outlined,
                        title: 'Course Code',
                        value: code,
                      ),
                      _infoCard(
                        icon: Icons.trending_up_rounded,
                        title: 'Course Level',
                        value: level,
                      ),
                      _infoCard(
                        icon: Icons.attach_money_rounded,
                        title: 'Price',
                        value: '\$$price',
                      ),

                      const SizedBox(height: 16),

                      // todo: class schedule
                      _buildSectionTitle('Schedule & Instructor'),
                      const SizedBox(height: 10),
                      _infoCard(
                        icon: Icons.person_rounded,
                        title: 'Teacher / Instructor',
                        value: teacher,
                      ),
                      _infoCard(
                        icon: Icons.schedule_rounded,
                        title: 'Study Time',
                        value: studyTime,
                      ),
                      _infoCard(
                        icon: Icons.timelapse_outlined,
                        title: 'Duration',
                        value: duration,
                      ),

                      const SizedBox(height: 16),

                      // todo: description section
                      _buildSectionTitle('Description'),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF334155),
                            height: 1.5,
                          ),
                        ),
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
                                builder: (_) => EditCourseScreen(
                                  courseId: courseId,
                                  courseData: data,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text(
                            'Edit Course Information',
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

                      // todo: delete button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteCourse(context, name),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text(
                            'Delete Course Record',
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

  // todo: section title
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

  // todo: info card
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

  Future<void> _deleteCourse(BuildContext context, String courseName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Course'),
          content: Text(
            'Are you sure you want to delete "$courseName"? This action cannot be undone.',
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
          .collection('courses')
          .doc(courseId)
          .delete();

      navigator.pop();
      navigator.pop();

      messenger.showSnackBar(
        const SnackBar(content: Text('Course deleted successfully.')),
      );
    } catch (e) {
      navigator.pop();

      messenger.showSnackBar(
        SnackBar(content: Text('Failed to delete course: $e')),
      );
    }
  }
}
