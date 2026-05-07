import 'package:flutter/material.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/widgets/app_image.dart';

class ModelCard extends StatelessWidget {
  final String title;
  final String scale;
  final double progress;
  final String status;
  final String? imageUrl;

  const ModelCard({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 2,
            child: AppImage(
              imageUrl: imageUrl,
              placeholder: Container(
                color: AppColors.lightGrey,
                child: const Icon(Icons.photo, color: AppColors.grey, size: 48),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: statusColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SCALE: $scale', // L10N (Hardcoded prefix is common in modeling)
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: (MediaQuery.sizeOf(context).width * 0.035).clamp(10.0, 12.0),
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyBlue,
                        letterSpacing: 1.2,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
