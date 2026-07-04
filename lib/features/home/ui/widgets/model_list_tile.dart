import 'package:flutter/material.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/widgets/app_image.dart';

class ModelListTile extends StatelessWidget {
  final String title;
  final String scale;
  final double progress;
  final String status;
  final String? imageUrl;

  const ModelListTile({
    super.key,
    required this.title,
    required this.scale,
    required this.progress,
    required this.status,
    this.imageUrl,
  });

  Color _getStatusColor() {
    switch (status.toUpperCase()) {
      case 'WARSZTAT':
        return Colors.lightBlueAccent;
      case 'PAUSED':
        return Colors.orange;
      case 'FINISHED':
        return Colors.green;
      default:
        return AppColors.navyBlue;
    }
  }

  String _getStatusText(BuildContext context) {
    switch (status.toUpperCase()) {
      case 'WARSZTAT':
        return S.of(context).statusInProgress;
      case 'PAUSED':
        return S.of(context).statusPaused;
      case 'FINISHED':
        return S.of(context).statusFinished;
      case 'GARDEROBA':
        return S.of(context).statusStash;
      case 'SPRZEDANE':
        return S.of(context).statusSold;
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: statusColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Project Image
          SizedBox(
            width: 120,
            height: double.infinity,
            child: AppImage(
              imageUrl: imageUrl,
              placeholder: Container(
                color: AppColors.lightGrey,
                child: const Icon(Icons.photo, color: AppColors.grey, size: 36),
              ),
            ),
          ),
          // Vertical Divider in status color
          Container(
            width: 3,
            color: statusColor,
          ),
          // Project Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header: Scale and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1:$scale', // Standard format
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: statusColor,
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Title
                  Text(
                    title.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navyBlue,
                          letterSpacing: 1.0,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Progress indicator
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: AppColors.lightGrey,
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${progress.toInt()}%',
                        style: const TextStyle(
                          color: AppColors.navyBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
