import 'package:flutter/material.dart';

/// Placeholder job card widget.
///
/// Will display job title, company, region, and salary.
class JobCard extends StatelessWidget {
  const JobCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        title: Text('Job Title'),
        subtitle: Text('Company • Region'),
      ),
    );
  }
}
