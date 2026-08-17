import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eschool_registration/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Import screens
import 'package:eschool_registration/screens/students/student_screen.dart';
import 'package:eschool_registration/screens/course/course_screen.dart';
import 'package:eschool_registration/screens/registration/registration_screen.dart';
import 'package:eschool_registration/screens/payments/payment_screen.dart';
import 'package:eschool_registration/screens/reports/report_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // ─────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────
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

      // ─────────────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'E-School Registration',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        // TODO: Logout
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),

      // ─────────────────────────────────────────────
      // DRAWER
      // ─────────────────────────────────────────────
      drawer: _buildDrawer(context, user),

      // ─────────────────────────────────────────────
      // BODY
      // ─────────────────────────────────────────────
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

              // Dashboard cards
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.15,
                children: [
                  // Students
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

                  // Courses
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

                  // Registration
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

                  // Payments
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
                    },
                  ),

                  // Reports
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

  // ─────────────────────────────────────────────
  // WELCOME CARD
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  // INFORMATION CARD
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  // DRAWER
  // ─────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context, User? user) {
    const primaryColor = Color(0xFF2563EB);
    const darkText = Color(0xFF1E293B);
    const grayText = Color(0xFF64748B);

    return Drawer(
      width: 300,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // ─────────────────────────────────────
            // DRAWER HEADER
            // ─────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================
                  // APP HEADER
                  // =========================
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 29,
                        ),
                      ),

                      const SizedBox(width: 13),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'E-School',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Registration System',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Divider
                  Container(height: 1, color: Colors.white.withOpacity(0.15)),

                  const SizedBox(height: 16),

                  // =========================
                  // ADMIN PROFILE
                  // =========================
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: primaryColor,
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Administrator',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(width: 7),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ADMIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  color: Colors.white.withOpacity(0.65),
                                  size: 13,
                                ),

                                const SizedBox(width: 5),

                                Expanded(
                                  child: Text(
                                    user?.email ?? 'No email',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.72),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─────────────────────────────────────
            // MENU TITLE
            // ─────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MAIN MENU',
                  style: TextStyle(
                    color: grayText,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            // Dashboard
            _drawerItem(
              context: context,
              icon: Icons.dashboard_rounded,
              title: 'Dashboard',
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // Students
            _drawerItem(
              context: context,
              icon: Icons.people_alt_rounded,
              title: 'Students',
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentScreen()),
                );
              },
            ),

            // Courses
            _drawerItem(
              context: context,
              icon: Icons.school_rounded,
              title: 'Courses',
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CourseScreen()),
                );
              },
            ),

            // Registration
            _drawerItem(
              context: context,
              icon: Icons.app_registration_rounded,
              title: 'Registration',
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                );
              },
            ),

            // Payments
            _drawerItem(
              context: context,
              icon: Icons.account_balance_wallet_rounded,
              title: 'Payments',
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentScreen()),
                );
              },
            ),

            // Reports
            _drawerItem(
              context: context,
              icon: Icons.bar_chart_rounded,
              title: 'Reports',
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportScreen()),
                );
              },
            ),

            const Spacer(),

            // ─────────────────────────────────────
            // DIVIDER
            // ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Colors.grey.shade200, thickness: 1),
            ),

            const SizedBox(height: 5),

            // ─────────────────────────────────────
            // LOGOUT
            // ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),

                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 21,
                  ),
                ),

                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.red,
                  size: 14,
                ),

                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),
            ),

            const SizedBox(height: 8),

            // Version
            const Text(
              'E-School Registration v1.0.0',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DRAWER ITEM
  // ─────────────────────────────────────────────
  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    const primaryColor = Color(0xFF2563EB);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        selected: selected,

        selectedTileColor: primaryColor.withOpacity(0.10),

        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: selected ? primaryColor : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 21,
            color: selected ? Colors.white : const Color(0xFF64748B),
          ),
        ),

        title: Text(
          title,
          style: TextStyle(
            color: selected ? primaryColor : const Color(0xFF334155),
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),

        trailing: selected
            ? const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: primaryColor,
              )
            : null,

        onTap: onTap,
      ),
    );
  }

  // TODO: Logout

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─────────────────────────────────────
                // LOGOUT ICON
                // ─────────────────────────────────────
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ─────────────────────────────────────
                // TITLE
                // ─────────────────────────────────────
                const Text(
                  'Logout',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // ─────────────────────────────────────
                // DESCRIPTION
                // ─────────────────────────────────────
                const Text(
                  'Are you sure you want to logout from\nyour account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // ─────────────────────────────────────
                // BUTTONS
                // ─────────────────────────────────────
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF475569),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            backgroundColor: const Color(0xFFF8FAFC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Logout
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext);

                            await _logout(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // MESSAGE SNACKBAR
  // ─────────────────────────────────────────────
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

// ═══════════════════════════════════════════════════
// DASHBOARD CARD
// ═══════════════════════════════════════════════════

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
            // Icon
            Container(
              height: 46,
              width: 46,

              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(13),
              ),

              child: Icon(icon, color: color, size: 25),
            ),

            const Spacer(),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 3),

            // Subtitle
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
