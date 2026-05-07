import 'package:flutter/material.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/widgets/app_image.dart';

class ShowcaseModelCard extends StatelessWidget {
  final String title;
  final String scale;
  final String? imageUrl;

  const ShowcaseModelCard({
    super.key,
    required this.title,
    required this.scale,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The Display Box (Museum style)
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AppImage(
                    imageUrl: imageUrl,
                    placeholder: Container(
                      color: Colors.white.withValues(alpha: 0.05),
                      child: const Icon(Icons.photo, color: Colors.white12, size: 48),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // The Pedestal / Plaque
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2C2C2C),
                const Color(0xFF1A1A1A),
              ],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Container(
                height: 1,
                width: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.red.withValues(alpha: 0.1),
                      AppColors.red,
                      AppColors.red.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'SCALE: $scale',
                style: const TextStyle(
                  color: AppColors.red,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
