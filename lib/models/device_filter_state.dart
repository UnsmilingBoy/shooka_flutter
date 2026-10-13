/// Enum representing the different device list modes
enum DeviceListMode {
  all, // Normal device list
  rejected, // Rejected devices (is_rejected=true)
  suspended, // Suspended/pending review devices (is_suspended=true)
}

/// Class to hold filter state for device lists
/// Prevents duplication of filter state variables across different modes
class DeviceFilterState {
  /// Comma-separated ids for multi-select (e.g. "1,2,3").
  String? selectedInstaller;
  String? searchedText;
  /// Comma-separated values for multi-select filters.
  String? selectedOrg;
  String? selectedAdmin;
  String? selectedProvince;
  String? selectedCity;
  String? selectedPlan;
  String? selectedFlowchart;
  String? startDate;
  String? endDate;
  int filterCount;

  // Pagination state
  int page;
  int totalPages;
  bool isNextPageLoading;

  // When true, the next list reload should preserve the current viewport
  // (e.g. after editing/saving a device)
  bool preserveScrollAfterReload;

  DeviceFilterState({
    this.selectedInstaller,
    this.searchedText,
    this.selectedOrg,
    this.selectedAdmin,
    this.selectedProvince,
    this.selectedCity,
    this.selectedPlan,
    this.selectedFlowchart,
    this.startDate,
    this.endDate,
    this.filterCount = 0,
    this.page = 1,
    this.totalPages = 1,
    this.isNextPageLoading = false,
    this.preserveScrollAfterReload = false,
  });

  /// Reset all filters to default
  void clearFilters() {
    selectedInstaller = null;
    selectedOrg = null;
    selectedAdmin = null;
    selectedProvince = null;
    selectedCity = null;
    selectedPlan = null;
    selectedFlowchart = null;
    startDate = null;
    endDate = null;
    filterCount = 0;
  }

  /// Update filter state from parameters and calculate filterCount.
  /// Multi-select values are passed as comma-separated strings
  /// (e.g. "1,2,3"). Empty strings are treated as null.
  void updateFilters({
    String? installer,
    String? organization,
    String? administration,
    String? province,
    String? city,
    String? plan,
    String? flowchart,
    String? start,
    String? end,
    String? search,
  }) {
    filterCount = 0;

    String? norm(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();

    final installerN = norm(installer);
    if (installerN != null) {
      selectedInstaller = installerN;
      filterCount++;
    } else {
      selectedInstaller = null;
    }

    final orgN = norm(organization);
    if (orgN != null) {
      selectedOrg = orgN;
      filterCount++;
    } else {
      selectedOrg = null;
    }

    final adminN = norm(administration);
    if (adminN != null) {
      selectedAdmin = adminN;
      filterCount++;
    } else {
      selectedAdmin = null;
    }

    final provinceN = norm(province);
    if (provinceN != null) {
      selectedProvince = provinceN;
      filterCount++;
    } else {
      selectedProvince = null;
    }

    final cityN = norm(city);
    if (cityN != null) {
      selectedCity = cityN;
      filterCount++;
    } else {
      selectedCity = null;
    }

    final planN = norm(plan);
    if (planN != null) {
      selectedPlan = planN;
      filterCount++;
    } else {
      selectedPlan = null;
    }

    final flowchartN = norm(flowchart);
    if (flowchartN != null) {
      selectedFlowchart = flowchartN;
      filterCount++;
    } else {
      selectedFlowchart = null;
    }

    final startN = norm(start);
    if (startN != null) {
      startDate = startN;
      filterCount++;
    } else {
      startDate = null;
    }

    if (end != null) {
      endDate = end;
    } else {
      endDate = null;
    }

    if (search != null) {
      searchedText = search;
    }

    if (filterCount == 0 && search == null) {
      searchedText = null;
    }
  }

  /// Reset pagination
  void resetPagination() {
    page = 1;
    totalPages = 1;
    isNextPageLoading = false;
  }

  /// Copy filter values for API call
  Map<String, dynamic> toApiParams() {
    return {
      'installer': selectedInstaller,
      'organization': selectedOrg,
      'administration': selectedAdmin,
      'province': selectedProvince,
      'city': selectedCity,
      'plan': selectedPlan,
      'flowchart': selectedFlowchart,
      'start': startDate,
      'end': endDate,
      'search': searchedText,
    };
  }
}
