import 'package:flutter/material.dart';

class StudentModel extends StatelessWidget {
  const StudentModel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Model')),
      body: const Center(child: Text('Welcome to the Student Model!')),
    );
  }
}
