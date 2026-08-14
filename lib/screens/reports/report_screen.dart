import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _reportType = 'Daily';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Report Management',
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
              'Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 2),

            const Text(
              'View enrollment and tuition payment reports',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 18),

            // Report type selector
            _buildReportTypeSelector(),

            const SizedBox(height: 14),

            // Date selector
            _buildDateSelector(),

            const SizedBox(height: 20),

            Expanded(child: _buildReportContent()),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REPORT TYPE SELECTOR
  // ============================================================

  Widget _buildReportTypeSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              title: 'Daily Report',
              icon: Icons.today_rounded,
              value: 'Daily',
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _buildTypeButton(
              title: 'Monthly Report',
              icon: Icons.calendar_month_rounded,
              value: 'Monthly',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String title,
    required IconData icon,
    required String value,
  }) {
    final bool selected = _reportType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _reportType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : const Color(0xFF64748B),
            ),

            const SizedBox(width: 7),

            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE SELECTOR
  // ============================================================

  Widget _buildDateSelector() {
    final String displayText;

    if (_reportType == 'Daily') {
      displayText =
          '${_selectedDate.day.toString().padLeft(2, '0')}/'
          '${_selectedDate.month.toString().padLeft(2, '0')}/'
          '${_selectedDate.year}';
    } else {
      displayText = '${_monthName(_selectedDate.month)} ${_selectedDate.year}';
    }

    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFF2563EB),
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _reportType == 'Daily' ? 'Selected Date' : 'Selected Month',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    displayText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    if (_reportType == 'Daily') {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

      if (picked != null) {
        setState(() {
          _selectedDate = picked;
        });
      }
    } else {
      await _selectMonth();
    }
  }

  Future<void> _selectMonth() async {
    int selectedYear = _selectedDate.year;
    int selectedMonth = _selectedDate.month;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Select Month',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedMonth,
                    decoration: InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: List.generate(12, (index) {
                      final month = index + 1;

                      return DropdownMenuItem<int>(
                        value: month,
                        child: Text(_monthName(month)),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedMonth = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<int>(
                    value: selectedYear,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: List.generate(DateTime.now().year - 2019, (index) {
                      final year = 2020 + index;

                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedYear = value;
                        });
                      }
                    },
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(selectedYear, selectedMonth, 1);
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // REPORT CONTENT
  // ============================================================
  // todo: report content
  Widget _buildReportContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('registrations').snapshots(),
      builder: (context, registrationSnapshot) {
        if (registrationSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (registrationSnapshot.hasError) {
          return Center(
            child: Text(
              'Error loading registrations:\n'
              '${registrationSnapshot.error}', 
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('payments').snapshots(),
          builder: (context, paymentSnapshot) {
            if (paymentSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (paymentSnapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading payments:\n'
                  '${paymentSnapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final registrations = registrationSnapshot.data?.docs ?? [];

            final payments = paymentSnapshot.data?.docs ?? [];

            final filteredRegistrations = registrations
                .where(_isDateInRange)
                .toList();

            final filteredPayments = payments.where(_isDateInRange).toList();

            final double totalRevenue = _calculateRevenue(filteredPayments);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReportHeader(),

                  const SizedBox(height: 16),

                  // Metrics
                  _buildMetricGrid(
                    enrollmentCount: filteredRegistrations.length,
                    paymentCount: filteredPayments.length,
                    revenue: totalRevenue,
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    'Payment Transactions',
                    filteredPayments.length,
                  ),

                  const SizedBox(height: 12),

                  if (filteredPayments.isEmpty)
                    _buildNoDataCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'No payments found',
                      subtitle:
                          'There are no payment transactions for this period.',
                    )
                  else
                    ...filteredPayments.map((doc) => _buildPaymentItem(doc)),

                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    'Course Enrollments',
                    filteredRegistrations.length,
                  ),

                  const SizedBox(height: 12),

                  if (filteredRegistrations.isEmpty)
                    _buildNoDataCard(
                      icon: Icons.school_outlined,
                      title: 'No enrollments found',
                      subtitle: 'There are no registrations for this period.',
                    )
                  else
                    ...filteredRegistrations.map(
                      (doc) => _buildRegistrationItem(doc),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // REPORT HEADER
  // ============================================================

  Widget _buildReportHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _reportType == 'Daily' ? 'Daily Report' : 'Monthly Report',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _reportType == 'Daily'
                      ? _formatDate(_selectedDate)
                      : '${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // METRIC GRID
  // ============================================================

  Widget _buildMetricGrid({
    required int enrollmentCount,
    required int paymentCount,
    required double revenue,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      children: [
        _buildMetricCard(
          icon: Icons.app_registration_rounded,
          title: 'Enrollments',
          value: enrollmentCount.toString(),
          color: const Color(0xFF2563EB),
        ),

        _buildMetricCard(
          icon: Icons.receipt_long_rounded,
          title: 'Payments',
          value: paymentCount.toString(),
          color: const Color(0xFF7C3AED),
        ),

        _buildMetricCard(
          icon: Icons.attach_money_rounded,
          title: 'Revenue',
          value: _formatMoney(revenue),
          color: const Color(0xFF059669),
        ),

        _buildMetricCard(
          icon: Icons.calendar_month_rounded,
          title: _reportType == 'Daily' ? 'Report Day' : 'Report Month',
          value: _reportType == 'Daily'
              ? '${_selectedDate.day}/${_selectedDate.month}'
              : _monthName(_selectedDate.month),
          color: const Color(0xFFEA580C),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 21),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),

        Text(
          'Total: $count',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT ITEM
  // ============================================================

  Widget _buildPaymentItem(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final studentName = (data['studentName'] ?? 'Unknown Student').toString();

    final courseName = (data['courseName'] ?? 'Unknown Course').toString();

    final amount = _toDouble(data['amount']);

    final method = (data['paymentMethod'] ?? 'Cash').toString();

    final reference = (data['referenceNo'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_rounded, color: Color(0xFF166534)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  courseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  reference.isEmpty ? method : '$method • $reference',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            '+${_formatMoney(amount)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF166534),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REGISTRATION ITEM
  // ============================================================

  Widget _buildRegistrationItem(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final studentName = (data['studentName'] ?? 'Unknown Student').toString();

    final courseName = (data['courseName'] ?? 'Unknown Course').toString();

    final courseCode = (data['courseCode'] ?? '').toString();

    final price = _toDouble(data['price']);

    final status = (data['status'] ?? 'Active').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: Color(0xFF2563EB)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  courseCode.isEmpty ? courseName : '$courseName ($courseCode)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Fee: ${_formatMoney(price)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          _buildStatusBadge(status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color background;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
        background = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        break;

      case 'cancelled':
        background = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        break;

      default:
        background = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  // ============================================================
  // NO DATA
  // ============================================================

  Widget _buildNoDataCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: const Color(0xFF94A3B8)),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FILTER
  // ============================================================

  bool _isDateInRange(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final timestamp = _getTimestamp(data);

    if (timestamp == null) {
      return false;
    }

    final date = timestamp.toDate();

    if (_reportType == 'Daily') {
      return date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
    }

    return date.year == _selectedDate.year && date.month == _selectedDate.month;
  }

  // ============================================================
  // GET TIMESTAMP
  // ============================================================

  Timestamp? _getTimestamp(Map<String, dynamic> data) {
    final possibleFields = [
      'createdAt',
      'paymentDate',
      'date',
      'paidAt',
      'transactionDate',
    ];

    for (final field in possibleFields) {
      final value = data[field];

      if (value is Timestamp) {
        return value;
      }

      if (value is DateTime) {
        return Timestamp.fromDate(value);
      }
    }

    return null;
  }

  // ============================================================
  // CALCULATE REVENUE
  // ============================================================

  double _calculateRevenue(List<QueryDocumentSnapshot> docs) {
    double total = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      total += _toDouble(data['amount']);
    }

    return total;
  }

  // ============================================================
  // NUMBER CONVERSION
  // ============================================================

  double _toDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ============================================================
  // FORMAT MONEY
  // ============================================================

  String _formatMoney(double amount) {
    if (amount == amount.roundToDouble()) {
      return '\$${amount.toInt()}';
    }

    return '\$${amount.toStringAsFixed(2)}';
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // MONTH NAME
  // ============================================================

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }
}
