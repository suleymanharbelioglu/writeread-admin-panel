import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Firebase Storage image loader for admin panel.
///
/// On web (CanvasKit), default [Image.network] fetches via XHR and fails when
/// Storage has no CORS headers. [WebHtmlElementStrategy.prefer] uses a native
/// native img tag instead, which loads public Storage URLs without CORS.
class StorageNetworkImage extends StatelessWidget {
  const StorageNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
    this.loadingWidget,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return errorWidget ?? const SizedBox.shrink();
    }

    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      webHtmlElementStrategy: kIsWeb
          ? WebHtmlElementStrategy.prefer
          : WebHtmlElementStrategy.never,
    errorBuilder: (_, _, _) =>
        errorWidget ??
        const Center(
          child: Icon(Icons.broken_image_outlined, size: 64),
        ),
      loadingBuilder: loadingWidget == null
          ? null
          : (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return loadingWidget!;
            },
    );
  }
}
