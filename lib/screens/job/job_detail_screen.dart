import 'package:flutter/material.dart';

/// Job detail screen — placeholder for Day 5 (spec_05).
///
/// Receives jobId from route parameter. Full implementation in Day 5.
class JobDetailScreen extends StatelessWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공고 상세')),
      body: Center(child: Text('Job Detail: $jobId')),
    );
  }
}
