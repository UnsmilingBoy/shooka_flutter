import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shooka_flutter/utils/image%20views/image_with_caption.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imagePathList;
  const ImageSlider({super.key, required this.imagePathList});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _currentIndex = 0;
  late CarouselSliderController _carouselController;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: MediaQuery.of(context).size.width > 600 ? 400.0 : 250.0,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 1,
                aspectRatio: 16 / 9,
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
              items: widget.imagePathList.map((item) {
                return Builder(
                  builder: (context) => ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: ImageWithCaption(
                      networkImagePath: item,
                      disableCaption: true,
                    ),
                  ),
                );
              }).toList(),
            ),
            // Previous button (web only)
            if (isWeb)
              Positioned(
                left: 16,
                child: IconButton(
                  onPressed: () => _carouselController.nextPage(),
                  icon: const Icon(Icons.chevron_right, size: 40),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(5),
                  ),
                  tooltip: 'تصویر بعدی',
                ),
              ),
            // Next button (web only)
            if (isWeb)
              Positioned(
                right: 16,
                child: IconButton(
                  onPressed: () => _carouselController.previousPage(),
                  icon: const Icon(Icons.chevron_left, size: 40),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(5),
                  ),
                  tooltip: 'تصویر قبلی',
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imagePathList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = entry.key),
              child: Container(
                width: _currentIndex == entry.key ? 8.0 : 6.0,
                height: _currentIndex == entry.key ? 8.0 : 6.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key
                      ? Colors.blueAccent
                      : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
