import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_payment_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedMethod = 'All Methods';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _goToAddPayment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPaymentScreen()),
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
          'Tuition Payments',
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
              'Payment History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'View student payment receipts and transaction records',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            // Record Payment Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _goToAddPayment,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Record Payment',
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

            // Search Bar & Payment Method Filter Row
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
                      hintText: 'Search by student or course...',
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
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Method Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMethod,
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
                            _selectedMethod = newValue;
                          });
                        }
                      },
                      items:
                          const [
                                'All Methods',
                                'ABA / Bank Transfer',
                                'Cash',
                                'Credit Card',
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

            // Live Payments Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('payments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No payment receipts found.',
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
                    final refNo = (data['referenceNo'] ?? '')
                        .toString()
                        .toLowerCase();
                    final method = (data['paymentMethod'] ?? '').toString();

                    final matchesSearch =
                        cleanQuery.isEmpty ||
                        studentName.contains(cleanQuery) ||
                        courseName.contains(cleanQuery) ||
                        refNo.contains(cleanQuery);

                    final matchesMethod =
                        _selectedMethod == 'All Methods' ||
                        method.toLowerCase() == _selectedMethod.toLowerCase();

                    return matchesSearch && matchesMethod;
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transactions',
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
                                  'No matching payments found.',
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
                                      data['studentName'] ?? 'Unknown';
                                  final courseName =
                                      data['courseName'] ?? 'Course';
                                  final amount = data['amount'] ?? 0;
                                  final method =
                                      data['paymentMethod'] ?? 'Cash';
                                  final refNo = data['referenceNo'] ?? '';

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
                                          0xFFDCFCE7,
                                        ),
                                        child: const Icon(
                                          Icons.receipt_rounded,
                                          color: Color(0xFF166534),
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
                                              'Course: $courseName',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                            if (refNo.toString().isNotEmpty)
                                              Text(
                                                'Ref: $refNo',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '+\$$amount',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF166534),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              method,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                          ),
                                        ],
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
