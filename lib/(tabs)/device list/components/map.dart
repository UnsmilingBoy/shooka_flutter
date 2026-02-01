import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class MapPickerModal extends StatefulWidget {
  const MapPickerModal({super.key});

  @override
  State<MapPickerModal> createState() => _MapPickerModalState();
}

class _MapPickerModalState extends State<MapPickerModal> {
  LatLng? selectedLocation;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Dio _dio = Dio();
  bool _isLocating = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'accept-language': 'fa',
        },
        options: Options(headers: {'User-Agent': 'ShoukaFlutterApp/1.0'}),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> results = response.data;
        setState(() {
          _searchResults = results
              .map(
                (result) => {
                  'display_name': result['display_name'],
                  'lat': double.parse(result['lat'].toString()),
                  'lon': double.parse(result['lon'].toString()),
                },
              )
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در جستجو'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(double lat, double lon) {
    final point = LatLng(lat, lon);
    setState(() {
      selectedLocation = point;
      _searchResults = [];
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
    _mapController.move(point, 16);
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLocating = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('دسترسی به موقعیت مکانی رد شد'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLocating = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('دسترسی به موقعیت مکانی به طور دائم رد شده است'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      final LatLng point = LatLng(pos.latitude, pos.longitude);

      setState(() {
        selectedLocation = point;
      });

      _mapController.move(point, 16);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطا در دریافت موقعیت مکانی'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final mapContent = Container(
      height: isDesktop ? screenHeight * 0.85 : screenHeight * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: isDesktop ? BorderRadius.circular(16) : BorderRadius.zero,
      ),
      child: ClipRRect(
        borderRadius: isDesktop ? BorderRadius.circular(16) : BorderRadius.zero,
        child: Stack(
          children: [
            /// 🌍 Map Layer
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(35.6892, 51.3890),
                  initialZoom: 13,
                  minZoom: 3,
                  maxZoom: 18,
                  onTap: (tapPosition, point) {
                    setState(() {
                      selectedLocation = point;
                      _searchResults = [];
                    });
                    _searchFocusNode.unfocus();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=o0BuBFntqzU1CidazAOK',
                    userAgentPackageName: 'com.shooka.app',
                  ),
                  if (selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedLocation!,
                          width: 50,
                          height: 50,
                          child: Icon(
                            Icons.location_on,
                            color: theme.colorScheme.error,
                            size: 50,
                            shadows: [
                              Shadow(
                                blurRadius: 3,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            /// 🔍 Search Bar & Results
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    // Search Input
                    Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      shadowColor: Colors.black.withOpacity(0.3),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          textDirection: TextDirection.rtl,
                          style: theme.textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'جستجوی آدرس یا مکان...',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                            prefixIcon: _isSearching
                                ? Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.search_rounded,
                                    color: theme.hintColor,
                                  ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: theme.hintColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchResults = [];
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {}); // Update suffix icon
                            Future.delayed(
                              const Duration(milliseconds: 600),
                              () {
                                if (value == _searchController.text &&
                                    mounted) {
                                  _searchLocation(value);
                                }
                              },
                            );
                          },
                          onSubmitted: _searchLocation,
                        ),
                      ),
                    ),

                    // Search Results
                    if (_searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: _searchResults.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              thickness: 1,
                              color: theme.dividerColor,
                            ),
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                leading: Icon(
                                  Icons.location_on_rounded,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                                title: Text(
                                  result['display_name'],
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _selectSearchResult(
                                  result['lat'],
                                  result['lon'],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            /// 📍 Current Location Button
            Positioned(
              bottom: 20,
              left: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                shadowColor: Colors.black.withOpacity(0.3),
                child: InkWell(
                  onTap: _goToCurrentLocation,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: _isLocating
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: theme.primaryColor,
                            ),
                          )
                        : Icon(
                            Icons.my_location_rounded,
                            color: theme.primaryColor,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),

            /// ✅ Confirm Button
            if (selectedLocation != null)
              Positioned(
                bottom: 20,
                right: 20,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(16),
                  shadowColor: theme.primaryColor.withOpacity(0.4),
                  child: InkWell(
                    onTap: () => Navigator.pop(context, selectedLocation),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تایید موقعیت',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            /// 📍 Selected Location Info
            if (selectedLocation != null && !isDesktop)
              Positioned(
                bottom: 90,
                right: 20,
                left: 20,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          Icon(
                            Icons.place_rounded,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${selectedLocation!.latitude.toStringAsFixed(6)}, ${selectedLocation!.longitude.toStringAsFixed(6)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    // Desktop: Show in Dialog, Mobile: Return content for bottom sheet
    if (isDesktop) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: mapContent,
      );
    } else {
      return mapContent;
    }
  }
}
