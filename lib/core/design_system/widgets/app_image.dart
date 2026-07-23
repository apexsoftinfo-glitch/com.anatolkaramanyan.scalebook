import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../services/image_service.dart';

class AppImage extends StatefulWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final int? cacheWidth;
  final int? cacheHeight;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  String? _resolvedPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initImage();
  }

  @override
  void didUpdateWidget(covariant AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _initImage();
    }
  }

  void _initImage() {
    final url = widget.imageUrl;
    if (url == null || url.isEmpty) {
      _resolvedPath = null;
      _isLoading = false;
      return;
    }

    // Instant synchronous check for local file paths
    if (!url.startsWith('http')) {
      final cleanPath = url.startsWith('file://') ? url.replaceFirst('file://', '') : url;
      try {
        if (File(cleanPath).existsSync()) {
          _resolvedPath = cleanPath;
          _isLoading = false;
          return;
        }
      } catch (_) {}
    }

    _isLoading = true;
    _resolveAsync(url);
  }

  Future<void> _resolveAsync(String url) async {
    final path = await GetIt.I<ImageService>().resolvePath(url);
    if (mounted && widget.imageUrl == url) {
      setState(() {
        _resolvedPath = path;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.imageUrl;
    if (url == null || url.isEmpty) {
      return _buildPlaceholder();
    }

    final resolved = _resolvedPath;
    if (resolved != null && resolved.isNotEmpty) {
      final file = File(resolved);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          cacheWidth: widget.cacheWidth,
          cacheHeight: widget.cacheHeight,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }

    if (!_isLoading && url.startsWith('http')) {
      return Image.network(
        url,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return widget.placeholder ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[900],
          child: const Icon(Icons.image_not_supported, color: Colors.white24),
        );
  }
}
