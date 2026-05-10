import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../services/image_service.dart';

class AppImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    if (imageUrl!.startsWith('http')) {
      return FutureBuilder<String>(
        future: GetIt.I<ImageService>().resolvePath(imageUrl!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final file = File(snapshot.data!);
            if (file.existsSync()) {
              return Image.file(
                file,
                fit: fit,
                width: width,
                height: height,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              );
            }
          }
          // If no local file found, use network
          return Image.network(
            imageUrl!,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        },
      );
    }

    return FutureBuilder<String>(
      future: GetIt.I<ImageService>().resolvePath(imageUrl!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final file = File(snapshot.data!);
          if (file.existsSync()) {
            return Image.file(
              file,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            );
          }
        }
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
  }
}
