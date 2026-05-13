import 'package:flutter/material.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/widgets/app_image.dart';

class ShowcaseModelListTile extends StatelessWidget {
  final String title;
  final String scale;
  final String? imageUrl;

  const ShowcaseModelListTile({
    super.key,
    required this.title,
    required this.scale,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              SizedBox(
                width: 120,
                child: AppImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              
              // Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          scale,
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Arrow Indicator
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
