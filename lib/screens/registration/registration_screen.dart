import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_registration_screen.dart';
import 'registration_detail_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All Status';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _goToAddRegistration() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRegistrationScreen()),
    );

    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Registration Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Registrations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Manage student course enrollments and payment statuses',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            // Add Registration Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _goToAddRegistration,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'New Enrollment',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

            // Persistent Search Bar & Status Filter Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (String newValue) {
                      setState(() {
                        _searchQuery = newValue.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search student or course...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Status Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      icon: const Icon(
                        Icons.filter_list_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedStatus = newValue;
                          });
                        }
                      },
                      items:
                          const [
                                'All Status',
                                'Active',
                                'Completed',
                                'Cancelled',
                              ]
                              .map(
                                (val) => DropdownMenuItem(
                                  value: val,
                                  child: Text(val),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Live Registrations Firestore Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('registrations')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No registrations found.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs.toList();
                  final cleanQuery = _searchQuery.trim();

                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final studentName = (data['studentName'] ?? '')
                        .toString()
                        .toLowerCase();
                    final courseName = (data['courseName'] ?? '')
                        .toString()
                        .toLowerCase();
                    final courseCode = (data['courseCode'] ?? '')
                        .toString()
                        .toLowerCase();
                    final status = (data['status'] ?? 'Active').toString();

                    final matchesSearch =
                        cleanQuery.isEmpty ||
                        studentName.contains(cleanQuery) ||
                        courseName.contains(cleanQuery) ||
                        courseCode.contains(cleanQuery);

                    final matchesStatus =
                        _selectedStatus == 'All Status' ||
                        status.toLowerCase() == _selectedStatus.toLowerCase();

                    return matchesSearch && matchesStatus;
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Registration List',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Total: ${filteredDocs.length}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filteredDocs.isEmpty
                            ? const Center(
                                child: Text(
                                  'No matching registrations found.',
                                  style: TextStyle(color: Color(0xFF64748B)),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filteredDocs.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final doc = filteredDocs[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  final studentName =
                                      data['studentName'] ?? 'Unknown Student';
                                  final courseName =
                                      data['courseName'] ?? 'Unknown Course';
                                  final courseCode = data['courseCode'] ?? '';
                                  final price = data['price'] ?? 0;
                                  final status = data['status'] ?? 'Active';
                                  final paymentStatus =
                                      data['paymentStatus'] ?? 'Pending';

                                  return Card(
                                    margin: EdgeInsets.zero,
                                    elevation: 0,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                RegistrationDetailScreen(
                                                  registrationId: doc.id,
                                                  registrationData: data,
                                                ),
                                          ),
                                        );
                                      },

                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      leading: CircleAvatar(
                                        radius: 24,
                                        backgroundColor: const Color(
                                          0xFFEFF6FF,
                                        ),
                                        child: Text(
                                          studentName.isNotEmpty
                                              ? studentName[0].toUpperCase()
                                              : 'S',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        studentName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Course: $courseName ($courseCode)',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Fee: \$$price • Payment: $paymentStatus',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: status == 'Active'
                                              ? const Color(0xFFDCFCE7)
                                              : status == 'Completed'
                                              ? const Color(0xFFEFF6FF)
                                              : const Color(0xFFFEE2E8),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
