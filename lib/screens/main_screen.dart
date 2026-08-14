import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eschool_registration/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// import screens
import 'package:eschool_registration/screens/students/student_screen.dart';
import 'package:eschool_registration/screens/course/course_screen.dart';
import 'package:eschool_registration/screens/registration/registration_screen.dart';
import 'package:eschool_registration/screens/payments/payment_screen.dart';
import 'package:eschool_registration/screens/reports/report_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // todo: logout function
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'E-School Registration',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),

      // Drawer
      drawer: _buildDrawer(context, user),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              _buildMainScreen(user),

              const SizedBox(height: 24),

              // Dashboard title
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 16),

              // Dashboard cards grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.15,
                children: [
                  // Student dashboard card
                  _DashboardCard(
                    icon: Icons.people_alt_rounded,
                    title: 'Students',
                    subtitle: 'Manage students',
                    color: const Color(0xFF2563EB),
                    opTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentScreen(),
                        ),
                      );
                    },
                  ),

                  // Courses dashboard card
                  _DashboardCard(
                    icon: Icons.school_rounded,
                    title: 'Courses',
                    subtitle: 'Manage courses',
                    color: const Color(0xFF7C3AED),
                    opTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CourseScreen()),
                      );
                    },
                  ),

                  // Registration dashboard card
                  _DashboardCard(
                    icon: Icons.app_registration_rounded,
                    title: 'Registration',
                    subtitle: 'Student registration',
                    color: const Color(0xFF059669),
                    opTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegistrationScreen(),
                        ),
                      );
                    },
                  ),

                  // Payment dashboard card
                  _DashboardCard(
                    icon: Icons.payment_rounded,
                    title: 'Payments',
                    subtitle: 'Manage payments',
                    color: const Color(0xFFEA580C),
                    opTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentScreen(),
                        ),
                      );
                      // _showMessage(context, 'Payment Management coming next!');
                    },
                  ),

                  _DashboardCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'Reports',
                    subtitle: 'Manage reports',
                    color: const Color(0xFF0D9488),
                    opTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportScreen()),
                      );
                      // _showMessage(context, 'Payment Management coming next!');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Quick Information
              const Text(
                'Quick Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 14),

              _buildInfoCard(
                icon: Icons.school_rounded,
                title: 'English School',
                subtitle: 'English School Registration Management System',
              ),

              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.email_outlined,
                title: 'Your Email',
                subtitle: user?.email ?? 'No email',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Welcome card
  Widget _buildMainScreen(User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_rounded,
              size: 34,
              color: Color(0xFF2563EB),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: user == null
                  ? null
                  : FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .snapshots(),

              builder: (context, snapshot) {
                String name = 'Student';

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  name = data['fullName'] ?? 'Student';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back 👋',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Information card
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Drawer
  Widget _buildDrawer(BuildContext context, User? user) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2563EB)),

            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person_rounded,
                size: 35,
                color: Color(0xFF2563EB),
              ),
            ),

            accountName: const Text(
              'E-School Registration',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            accountEmail: Text(user?.email ?? 'No email'),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text('Dashboard'),
            selected: true,
            selectedColor: const Color(0xFF2563EB),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.people_alt_rounded),
            title: const Text('Students'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentScreen()),
              );
              // _showMessage(context, 'Students Management coming next!');
            },
          ),

          ListTile(
            leading: const Icon(Icons.school_rounded),
            title: const Text('Courses'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CourseScreen()),
              );
              // _showMessage(context, 'Courses Management coming next!');
            },
          ),

          ListTile(
            leading: const Icon(Icons.app_registration_rounded),
            title: const Text('Registration'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistrationScreen()),
              );
              // _showMessage(context, 'Registration Management coming next!');
            },
          ),

          ListTile(
            leading: const Icon(Icons.payment_rounded),
            title: const Text('Payments'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentScreen()),
              );
              // _showMessage(context, 'Payment Management coming next!');
            },
          ),

          ListTile(
            leading: const Icon(Icons.payment_rounded),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportScreen()),
              );
              // _showMessage(context, 'Report Management coming next!');
            },
          ),

          const Spacer(),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Logout Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 15),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logout(context);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Message SnackBar
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
  }
}

// Dashboard card
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback opTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.opTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: opTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 25),
            ),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
