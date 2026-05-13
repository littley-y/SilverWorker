import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/job_model.dart';
import 'gray_chip.dart';
import 'intensity_pill.dart';

/// Job posting card widget aligned with spec_12.
///
/// Displays intensity pill, title, company, salary,
/// and bottom meta chips (employment type, distance, deadline).
/// Entire card is tappable → navigates to JobDetailScreen.
class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  /// Removes trailing "모집" from the title.
  String get _displayTitle {
    return job.title.trim().replaceAll(RegExp(r'모집$'), '').trim();
  }

  /// Formats deadline as "D-n" or "D-day" or "마감" if passed.
  static String _formatDeadline(DateTime? deadline) {
    if (deadline == null) return '상시';
    final now = DateTime.now();
    final diff = deadline.difference(now).inDays;
    if (diff < 0) return '마감';
    if (diff == 0) return 'D-day';
    return 'D-$diff';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Intensity pill (left) + Salary (right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntensityPill(physicalIntensity: job.physicalIntensity),
                  const Spacer(),
                  Text(
                    job.formattedSalary,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Row 2: Title
              Text(
                _displayTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Row 3: Company name
              Text(
                job.companyName,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Row 4: Meta chips (employment, distance, deadline)
              Row(
                children: [
                  GrayChip(label: job.employmentTypeLabel),
                  if (job.walkingMinutes != null) ...[
                    const SizedBox(width: 8),
                    GrayChip(
                      label: '도보 ${job.walkingMinutes}분',
                      icon: '🚶',
                    ),
                  ],
                  const SizedBox(width: 8),
                  GrayChip(label: _formatDeadline(job.deadline)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
