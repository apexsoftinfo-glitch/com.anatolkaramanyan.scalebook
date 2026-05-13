import 'package:flutter/material.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/widgets/app_image.dart';

class StashModelListTile extends StatelessWidget {
  final String title;
  final String scale;
  final String? imageUrl;
  final VoidCallback onTap;

  const StashModelListTile({
    super.key,
    required this.title,
    required this.scale,
    required this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppImage(
                  imageUrl: imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.navyBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      scale,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions Icon
              const Icon(Icons.more_vert, color: AppColors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
