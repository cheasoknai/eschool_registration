import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eschool_registration/screens/students/add_student_screen.dart';
import 'package:eschool_registration/screens/students/student_detail_screen.dart';
import 'package:flutter/material.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedClass = 'All Classes';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Student Management',
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
              'Students',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Manage student information and class rosters',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            // Add Student Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddStudentScreen()),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add Student',
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

            // Search Bar & Class Filter Row (Placed outside StreamBuilder to keep TextField focus persistent)
            SizedBox(height: 12),
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
                      hintText: 'Search by ID, name, email...',
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
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Class Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedClass,
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
                            _selectedClass = newValue;
                          });
                        }
                      },
                      items:
                          const [
                            'All Classes',
                            'Grade 1',
                            'Grade 2',
                            'Grade 3',
                            'Grade 4',
                            'Grade 5',
                            'Grade 6',
                            'Grade 7',
                            'Grade 8',
                            'Grade 9',
                            'Grade 10',
                            'Grade 11',
                            'Grade 12',
                            'General',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Firestore Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('students')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final docs = snapshot.data!.docs.toList();

                  // Extract all unique classes dynamically from student records
                  final Set<String> classSet = {'All Classes'};
                  for (var doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final studentClass =
                        data['className'] ?? data['class'] ?? data['grade'];
                    if (studentClass != null &&
                        studentClass.toString().trim().isNotEmpty) {
                      classSet.add(studentClass.toString().trim());
                    }
                  }
                  final availableClasses = classSet.toList()..sort();

                  // Validate current selection safely without calling setState in build
                  final activeClassFilter =
                      availableClasses.contains(_selectedClass)
                      ? _selectedClass
                      : 'All Classes';

                  // Sort client-side by Student ID in ascending order (1 to N)
                  docs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;

                    final aIdRaw = aData['studentId'] ?? aData['id'] ?? '';
                    final bIdRaw = bData['studentId'] ?? bData['id'] ?? '';

                    final aNum = int.tryParse(aIdRaw.toString());
                    final bNum = int.tryParse(bIdRaw.toString());

                    if (aNum != null && bNum != null) {
                      return aNum.compareTo(bNum);
                    } else if (aNum != null) {
                      return -1;
                    } else if (bNum != null) {
                      return 1;
                    }

                    final aTime = aData['createdAt'] as Timestamp?;
                    final bTime = bData['createdAt'] as Timestamp?;
                    if (aTime == null || bTime == null) return 0;
                    return aTime.compareTo(bTime);
                  });

                  // Client-side search + Class filtering
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final docId = doc.id.toLowerCase();
                    final customId = (data['studentId'] ?? data['id'] ?? '')
                        .toString()
                        .toLowerCase();
                    final name = (data['fullName'] ?? '')
                        .toString()
                        .toLowerCase();
                    final email = (data['email'] ?? '')
                        .toString()
                        .toLowerCase();
                    final phone = (data['phone'] ?? '')
                        .toString()
                        .toLowerCase();
                    final studentClass =
                        (data['className'] ??
                                data['class'] ??
                                data['grade'] ??
                                '')
                            .toString();

                    final matchesSearch =
                        docId.contains(_searchQuery) ||
                        customId.contains(_searchQuery) ||
                        name.contains(_searchQuery) ||
                        email.contains(_searchQuery) ||
                        phone.contains(_searchQuery) ||
                        studentClass.toLowerCase().contains(_searchQuery);

                    final matchesClass =
                        activeClassFilter == 'All Classes' ||
                        studentClass.trim().toLowerCase() ==
                            activeClassFilter.toLowerCase();

                    return matchesSearch && matchesClass;
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // List Header with count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Student List',
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

                      // Student List
                      Expanded(
                        child: filteredDocs.isEmpty
                            ? const Center(
                                child: Text(
                                  'No matching students found.',
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

                                  final displayId =
                                      data['studentId'] ??
                                      data['id'] ??
                                      '${index + 1}';
                                  final name =
                                      (data['fullName'] ?? 'Unknown Student')
                                          .toString()
                                          .trim();
                                  final email = data['email'] ?? 'No email';
                                  final phone = data['phone'] ?? 'No phone';
                                  final gender =
                                      data['gender'] ?? 'Not specified';
                                  final studentClass =
                                      data['className'] ??
                                      data['class'] ??
                                      data['grade'] ??
                                      'Unassigned';

                                  final initialLetter = name.isNotEmpty
                                      ? name[0].toUpperCase()
                                      : '?';

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
                                          initialLetter,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: const Color(0xFFBFDBFE),
                                              ),
                                            ),
                                            child: Text(
                                              studentClass.toString(),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Student ID: $displayId',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              email.toString(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$phone • $gender',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => StudentDetailScreen(
                                              studentId: doc.id,
                                              studentData: data,
                                            ),
                                          ),
                                        );
                                      },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 16),
          Text(
            'No Students Registered',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first student to get started',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
