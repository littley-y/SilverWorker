import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/job_model.dart';

/// Job posting card widget aligned with spec_04 §2.
///
/// Displays title, company, salary, employment type chip,
/// deadline (D-n), and physical intensity badge.
/// Entire card is tappable → navigates to JobDetailScreen.
class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Title (left) + Salary (right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: AppTextStyles.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      job.formattedSalary,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Row 2: Company name
                Text(
                  job.companyName,
                  style: AppTextStyles.sectionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Row 3: Employment chip (left) + Deadline & Intensity (right)
                Row(
                  children: [
                    _EmploymentTypeChip(job: job),
                    const Spacer(),
                    Text(
                      _formatDeadline(job.deadline),
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(width: 8),
                    _IntensityBadge(job: job),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}

/// Employment type chip — small pill with light gray background.
class _EmploymentTypeChip extends StatelessWidget {
  final JobModel job;

  const _EmploymentTypeChip({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        job.employmentTypeLabel,
        style: AppTextStyles.caption,
      ),
    );
  }
}

/// Physical intensity badge — colored icon + text.
class _IntensityBadge extends StatelessWidget {
  final JobModel job;

  const _IntensityBadge({required this.job});

  Color get _color => switch (job.physicalIntensity) {
        'light' => AppColors.intensityLight,
        'moderate' => AppColors.intensityModerate,
        'heavy' => AppColors.intensityHeavy,
        _ => AppColors.intensityModerate,
      };

  IconData get _icon => switch (job.physicalIntensity) {
        'light' => Icons.fitness_center_outlined,
        'moderate' => Icons.fitness_center,
        'heavy' => Icons.engineering,
        _ => Icons.fitness_center,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 16, color: _color),
        const SizedBox(width: 2),
        Text(
          job.physicalIntensityLabel,
          style: TextStyle(fontSize: 14, color: _color),
        ),
      ],
    );
  }
}
