/// Enum representing the different device list modes
enum DeviceListMode {
  all, // Normal device list
  rejected, // Rejected devices (is_rejected=true)
  suspended, // Suspended/pending review devices (is_suspended=true)
}

/// Class to hold filter state for device lists
/// Prevents duplication of filter state variables across different modes
class DeviceFilterState {
  int? selectedInstaller;
  String? searchedText;
  String? selectedOrg;
  String? selectedAdmin;
  String? selectedProvince;
  String? selectedCity;
  String? selectedPlan;
  String? startDate;
  String? endDate;
  int filterCount;

  // Pagination state
  int page;
  int totalPages;
  bool isNextPageLoading;

  DeviceFilterState({
    this.selectedInstaller,
    this.searchedText,
    this.selectedOrg,
    this.selectedAdmin,
    this.selectedProvince,
    this.selectedCity,
    this.selectedPlan,
    this.startDate,
    this.endDate,
    this.filterCount = 0,
    this.page = 1,
    this.totalPages = 1,
    this.isNextPageLoading = false,
  });

  /// Reset all filters to default
  void clearFilters() {
    selectedInstaller = null;
    selectedOrg = null;
    selectedAdmin = null;
    selectedProvince = null;
    selectedCity = null;
    selectedPlan = null;
    startDate = null;
    endDate = null;
    filterCount = 0;
  }

  /// Update filter state from parameters and calculate filterCount
  void updateFilters({
    int? installer,
    String? organization,
    String? administration,
    String? province,
    String? city,
    String? plan,
    String? start,
    String? end,
    String? search,
  }) {
    filterCount = 0;

    if (installer != null) {
      selectedInstaller = installer;
      filterCount++;
    } else {
      selectedInstaller = null;
    }

    if (organization != null) {
      selectedOrg = organization;
      filterCount++;
    } else {
      selectedOrg = null;
    }

    if (administration != null) {
      selectedAdmin = administration;
      filterCount++;
    } else {
      selectedAdmin = null;
    }

    if (province != null) {
      selectedProvince = province;
      filterCount++;
    } else {
      selectedProvince = null;
    }

    if (city != null) {
      selectedCity = city;
      filterCount++;
    } else {
      selectedCity = null;
    }

    if (plan != null) {
      selectedPlan = plan;
      filterCount++;
    } else {
      selectedPlan = null;
    }

    if (start != null) {
      startDate = start;
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
      'start': startDate,
      'end': endDate,
      'search': searchedText,
    };
  }
}
