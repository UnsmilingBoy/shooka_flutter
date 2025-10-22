import 'package:flutter/material.dart';

class ImageWithCaption extends StatelessWidget {
  final String? localImagepath;
  final String? networkImagePath;
  final String? caption;
  final bool? disableCaption;

  const ImageWithCaption({
    super.key,
    this.caption,
    this.disableCaption,
    this.localImagepath,
    this.networkImagePath,
  });

  @override
  Widget build(BuildContext context) {
    Widget networkPreview(String url, {BoxFit? fit}) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (localImagepath != null) {
            return Image.asset(localImagepath!, fit: fit ?? BoxFit.contain);
          }
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.broken_image, size: 32, color: Colors.grey),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              minScale: 0.5,
              maxScale: 4,
              child: networkImagePath != null
                  ? networkPreview(networkImagePath!)
                  : (localImagepath != null
                        ? Image.asset(localImagepath!)
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 32,
                                color: Colors.grey,
                              ),
                            ),
                          )),
            ),
          ),
        ),
      ),
      child: Stack(
        children: [
          //
          // Image Preview
          //
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: networkImagePath != null
                  ? networkPreview(networkImagePath!, fit: BoxFit.cover)
                  : (localImagepath != null
                        ? Image.asset(localImagepath!, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 32,
                                color: Colors.grey,
                              ),
                            ),
                          )),
            ),
          ),

          //
          // Caption Overlay
          //
          if (disableCaption == null || disableCaption != true)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  caption ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
