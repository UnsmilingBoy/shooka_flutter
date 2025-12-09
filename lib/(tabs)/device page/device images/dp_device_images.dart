import 'dart:developer';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';
import 'package:universal_html/html.dart' as html;
import 'package:shooka_flutter/services/multiple_image_service.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/image%20views/image_with_caption.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';

class DeviceImages extends StatefulWidget {
  const DeviceImages({super.key});

  @override
  State<DeviceImages> createState() => _DeviceImagesState();
}

class _DeviceImagesState extends State<DeviceImages> {
  // store selected image indices (you can also store ids if available)
  final Set<int> _selected = {};
  final List<int> selectedForRemove = [];
  // Holds base64-encoded images selected by the user
  List<String> base64Images = [];
  bool isExporting = false;

  Future<void> _exportSelectedImages(List<dynamic> images) async {
    if (_selected.isEmpty) return;

    setState(() {
      isExporting = true;
    });

    try {
      final archive = Archive();
      final dio = Dio();

      // Download and add each selected image to the archive
      for (int index in _selected) {
        if (index < images.length) {
          final imageItem = images[index];
          final imageUrl = imageItem.image;

          try {
            // Download image
            final response = await dio.get(
              imageUrl,
              options: Options(responseType: ResponseType.bytes),
            );

            // Get file extension from URL or default to jpg
            String extension = 'jpg';
            if (imageUrl.contains('.')) {
              final urlParts = imageUrl.split('.');
              extension = urlParts.last.split('?').first;
            }

            // Add image to archive
            final fileName = 'image_${index + 1}.$extension';
            archive.addFile(
              ArchiveFile(fileName, response.data.length, response.data),
            );
          } catch (e) {
            log('Error downloading image $index: $e');
          }
        }
      }

      if (archive.isEmpty) {
        if (mounted) {
          flatErrorToast(title: 'خطا در دانلود تصاویر');
        }
        return;
      }

      // Encode archive to zip
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      if (zipData != null) {
        final fileName =
            'device_images_${DateTime.now().millisecondsSinceEpoch}.zip';

        // For web platform
        if (kIsWeb) {
          final blob = html.Blob([zipData]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)
            ..setAttribute('download', fileName)
            ..click();
          html.Url.revokeObjectUrl(url);
        }
        // For Windows, Linux, macOS, and Android platforms
        else if (!kIsWeb) {
          try {
            // Get downloads directory
            Directory? directory;
            if (Platform.isWindows) {
              // For Windows, use the Downloads folder
              final userProfile = Platform.environment['USERPROFILE'];
              if (userProfile != null) {
                directory = Directory('$userProfile\\Downloads');
              }
            } else if (Platform.isAndroid) {
              // For Android, use the public Downloads directory
              directory = Directory('/storage/emulated/0/Download');
            } else {
              // For other platforms (Linux, macOS, iOS)
              directory = await getDownloadsDirectory();
            }

            if (directory != null) {
              final filePath =
                  '${directory.path}${Platform.pathSeparator}$fileName';
              final file = File(filePath);
              await file.writeAsBytes(zipData);

              if (mounted) {
                filledSuccessToast(title: 'فایل در پوشه Downloads ذخیره شد');
              }
            } else {
              if (mounted) {
                flatErrorToast(title: 'خطا در پیدا کردن پوشه دانلود');
              }
            }
          } catch (e) {
            log('Error saving file: $e');
            if (mounted) {
              flatErrorToast(title: 'خطا در ذخیره فایل');
            }
          }
        }

        if (mounted && kIsWeb) {
          filledSuccessToast(title: 'تصاویر با موفقیت دانلود شد');
        }
      }
    } catch (e) {
      log('Error exporting images: $e');
      if (mounted) {
        flatErrorToast(title: 'خطا در ایجاد فایل فشرده');
      }
    } finally {
      if (mounted) {
        setState(() {
          isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();

    final images = deviceProvider.completeDeviceInfo?.engineroomImages ?? [];

    return MyExpansionTile(
      title: "مدیریت تصاویر موتورخانه",
      children: [
        images.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  "تصویری برای این موتورخانه اضافه نشده است.",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              )
            : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final imageItem = images[index];
                  final isSelected = _selected.contains(index);
                  return ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ImageWithCaption(
                          networkImagePath: imageItem.image,
                          disableCaption: true,
                        ),
                      ),
                    ),
                    title: Text(
                      "تصویر شماره ${index + 1}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      imageItem.createdAt,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selected.add(index);
                            selectedForRemove.add(imageItem.imageId);
                            if (kDebugMode) {
                              print(selectedForRemove);
                            }
                          } else {
                            _selected.remove(index);
                            selectedForRemove.remove(imageItem.imageId);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
        if (base64Images.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "تصاویر انتخاب شده برای اضافه کردن: ${base64Images.length}",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Row(
                spacing: 5,
                children: [
                  MyIconButton(
                    onPressed: () async {
                      setState(() {
                        base64Images.clear();
                      });
                    },
                    border: Border.all(color: Colors.grey.shade700),
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    child: Icon(
                      Icons.clear,
                      size: 15,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  MyIconButton(
                    onPressed: () async {
                      await deviceProvider.addEngineroomPicture(
                        deviceId: deviceProvider.device?.id ?? -1,
                        images: base64Images,
                      );
                      setState(() {
                        base64Images.clear();
                      });
                    },
                    border: Border.all(color: Colors.grey.shade700),
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    child: deviceProvider.updateCompleteInfoLoading == true
                        ? Loading(size: 15)
                        : Icon(
                            Icons.save,
                            size: 15,
                            color: Theme.of(context).hintColor,
                          ),
                  ),
                ],
              ),
            ],
          ),
        SizedBox(height: 10),
        Column(
          spacing: 10,
          children: [
            ContainerButton(
              borderRadius: 10,
              onPressed: () async {
                // pick multiple images and store as base64 strings
                final imageService = ImageService();
                final images = await imageService.pickMultipleImages();
                if (images.isNotEmpty) {
                  setState(() {
                    base64Images = images;
                  });
                }
                log(base64Images.length.toString());
              },
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.all(15),
              fillWidth: true,
              child: Text(
                "اضافه کردن تصویر جدید",
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.apply(color: Colors.white),
              ),
            ),
            if (selectedForRemove.isNotEmpty)
              ContainerButton(
                borderRadius: 10,
                onPressed: () async {
                  await deviceProvider.removeEngineroomPictures(
                    deviceId: deviceProvider.device?.id ?? -1,
                    imageId: selectedForRemove,
                  );
                  setState(() {
                    _selected.clear();
                    selectedForRemove.clear();
                  });
                },
                color: Theme.of(context).colorScheme.error,
                padding: EdgeInsets.all(15),
                fillWidth: true,
                child: deviceProvider.removeImageLoading
                    ? Loading()
                    : Text(
                        "حذف تصاویر انتخاب شده",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
              ),
            if (selectedForRemove.isNotEmpty)
              ContainerButton(
                borderRadius: 10,
                onPressed: isExporting
                    ? null
                    : () async {
                        await _exportSelectedImages(images);
                      },
                color: Theme.of(context).primaryColor.withOpacity(0.8),
                padding: EdgeInsets.all(15),
                fillWidth: true,
                child: isExporting
                    ? Loading()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "دانلود تصاویر انتخاب شده (ZIP)",
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium?.apply(color: Colors.white),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ],
    );
  }
}
