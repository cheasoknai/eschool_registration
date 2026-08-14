import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// import screen
import 'add_course_screen.dart';
import 'course_detail_screen.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedLevel = 'All Levels';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // todo: navigate add course
  Future<void> _goToAddCourse() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCourseScreen()),
    );

    if (result == true) {
      setState(() {});
    }
  }

  // build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Course Management',
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
              'Courses',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Manage course information and available classes',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            // todo: Add Course Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _goToAddCourse,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add Course',
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

            // todo: search bar
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
                      hintText: 'Search by code, name, teacher...',
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

                // todo: levels dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLevel,
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
                            _selectedLevel = newValue;
                          });
                        }
                      },
                      items:
                          const [
                            'All Levels',
                            'Primary',
                            'Secondary',
                            'High School',
                            'University',
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
                    .collection('courses')
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

                  // todo: filter dropdown
                  final Set<String> levelSet = {'All Levels'};
                  for (var doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final level = data['level'] ?? data['category'];
                    if (level != null && level.toString().trim().isNotEmpty) {
                      levelSet.add(level.toString().trim());
                    }
                  }
                  final availableLevels = levelSet.toList()..sort();

                  final activeLevelFilter =
                      availableLevels.contains(_selectedLevel)
                      ? _selectedLevel
                      : 'All Levels';

                  // Client-side sort by Course Name ascending
                  docs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;

                    final aName = (aData['name'] ?? '')
                        .toString()
                        .toLowerCase();
                    final bName = (bData['name'] ?? '')
                        .toString()
                        .toLowerCase();

                    return aName.compareTo(bName);
                  });

                  // Filter by Search Query and Level Dropdown
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final docId = doc.id.toLowerCase();
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final code = (data['code'] ?? '').toString().toLowerCase();
                    final teacher = (data['teacher'] ?? '')
                        .toString()
                        .toLowerCase();
                    final duration = (data['duration'] ?? '')
                        .toString()
                        .toLowerCase();
                    final level = (data['level'] ?? data['category'] ?? '')
                        .toString();

                    final matchesSearch =
                        docId.contains(_searchQuery) ||
                        name.contains(_searchQuery) ||
                        code.contains(_searchQuery) ||
                        teacher.contains(_searchQuery) ||
                        duration.contains(_searchQuery) ||
                        level.toLowerCase().contains(_searchQuery);

                    final matchesLevel =
                        activeLevelFilter == 'All Levels' ||
                        level.trim().toLowerCase() ==
                            activeLevelFilter.toLowerCase();

                    return matchesSearch && matchesLevel;
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // List Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Course List',
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

                      // Course List
                      Expanded(
                        child: filteredDocs.isEmpty
                            ? const Center(
                                child: Text(
                                  'No matching courses found.',
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

                                  final name =
                                      (data['name'] ?? 'Unknown Course')
                                          .toString()
                                          .trim();
                                  final code = (data['code'] ?? 'No Code')
                                      .toString();
                                  final teacher =
                                      (data['teacher'] ?? 'No Teacher')
                                          .toString();
                                  final duration =
                                      (data['duration'] ?? 'No Duration')
                                          .toString();
                                  final price = data['price'] ?? 0;

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
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
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
                                              code,
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
                                              'Teacher: $teacher',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Duration: $duration • Price: \$$price',
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
                                            builder: (_) => CourseDetailScreen(
                                              courseId: doc.id,
                                              courseData: data,
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

  // todo: empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.school_outlined, size: 64, color: Color(0xFF94A3B8)),
          SizedBox(height: 16),
          Text(
            'No Courses Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first course to get started',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
