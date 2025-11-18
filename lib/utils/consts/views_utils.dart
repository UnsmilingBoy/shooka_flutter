String? getMain3DViewById({
  required dynamic features,
  required int id,
  bool? returnNameOnly,
}) {
  if (features == null || features is! List || features.isEmpty) {
    return null;
  }

  final feature = features.firstWhere(
    (f) => f != null && f['id'] == id,
    orElse: () => null,
  );

  if (feature == null) {
    return null;
  }

  if (returnNameOnly == true) {
    return feature['main_3d_view'];
  }
  // Return the full URL from the API response
  return feature['main_3d_view_url'];
}
