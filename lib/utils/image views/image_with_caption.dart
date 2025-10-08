import 'package:flutter/material.dart';

class ImageWithCaption extends StatelessWidget {
  final String imagepath;
  final String? caption;
  final bool? disableCaption;

  const ImageWithCaption({
    super.key,
    required this.imagepath,
    this.caption,
    this.disableCaption,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          insetPadding: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            child: Column(
              spacing: 15,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(image: AssetImage(imagepath)),
                if (disableCaption == null || disableCaption != true)
                  Text(caption!),
              ],
            ),
          ),
        ),
      ),
      child: Stack(
        children: [
          //
          // View Image
          //
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(imagepath, fit: BoxFit.cover),
            ),
          ),

          //
          // View Name
          //
          if (disableCaption == null || disableCaption != true)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0, // <-- fill width
              child: Container(
                padding: const EdgeInsets.all(8), // optional padding
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(150),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  caption!,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
