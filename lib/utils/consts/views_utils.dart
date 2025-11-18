String? getMain3DViewById({
  required dynamic features,
  required int id,
  bool? returnNameOnly,
}) {
  final feature = features.firstWhere((f) => f['id'] == id, orElse: () => {});
  if (returnNameOnly == true) {
    return feature.isNotEmpty ? feature['main_3d_view'] : null;
  }
  // Return the full URL from the API response
  return feature.isNotEmpty ? feature['main_3d_view_url'] : null;
}
