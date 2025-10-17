import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/services/multiple_image_service.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
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

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();

    final images = deviceProvider.completeDeviceInfo?.engineroomImages ?? [];

    return MyExpansionTile(
      title: "مدیریت تصاویر موتورخانه",
      children: [
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: images.length,
          itemBuilder: (context, index) {
            final imageItem = images[index];
            final isSelected = _selected.contains(index);
            return ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: Image.network(imageItem.image),
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
                      print(selectedForRemove);
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
                style: Theme.of(context).textTheme.labelMedium,
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
          ],
        ),
      ],
    );
  }
}
