import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/add_device_modal.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/filter_device_modal.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/device_tile.dart';
import 'package:shooka_flutter/(tabs)/device%20page/device_detail_panel.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/models/app_panel.dart';
import 'package:shooka_flutter/models/device_data_class.dart';
import 'package:shooka_flutter/models/device_filter_state.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

/// Base device list widget that can be configured for different modes
class BaseDeviceList extends StatefulWidget {
  final bool openAddDevice;
  final DeviceListMode mode;

  const BaseDeviceList({
    super.key,
    required this.openAddDevice,
    this.mode = DeviceListMode.all,
  });

  @override
  State<BaseDeviceList> createState() => _BaseDeviceListState();
}

class _BaseDeviceListState extends State<BaseDeviceList> {
  final ScrollController _scrollController = ScrollController();
  late final DeviceProvider _deviceProvider;
  bool _exportLoading = false;

  // Split view state
  int? _selectedDeviceId;
  String? _selectedDeviceName;

  // Helper getters for mode checks
  bool get isRejectedMode => widget.mode == DeviceListMode.rejected;
  bool get isSuspendedMode => widget.mode == DeviceListMode.suspended;
  bool get isSpecialMode => isRejectedMode || isSuspendedMode;

  @override
  void initState() {
    super.initState();

    _deviceProvider = context.read<DeviceProvider>();

    Future.microtask(() async {
      await _deviceProvider.loadDevicesForMode(
        mode: widget.mode,
        all: false,
        page: 1,
      );
      // Check after initial load completes
      if (mounted) {
        _checkAndLoadMoreIfNeeded();
      }
    });

    _scrollController.addListener(_onScroll);

    // Listen to device provider changes and check if more items needed
    _deviceProvider.addListener(_onDeviceListChanged);

    // Opens the add device modal if the route was "/add_device" and user has permission
    if (widget.openAddDevice && widget.mode == DeviceListMode.all) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final canAdd = context.read<UserProvider>().accessControl.hasAccessTo(
          AppPanel.addDeviceFunctionality,
        );
        if (!canAdd) return;

        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth > 900;
        if (isDesktop) {
          showDialog(context: context, builder: (context) => AddDeviceModal());
        } else {
          showMaterialModalBottomSheet(
            enableDrag: false,
            context: context,
            builder: (context) => AddDeviceModal(),
          );
        }
      });
    }
  }

  void _onDeviceListChanged() {
    // Check after list updates (e.g., after add/edit/delete)
    final isLoading = _deviceProvider.getLoading(widget.mode);
    if (mounted && !isLoading) {
      // Update selected device name if it's currently selected
      if (_selectedDeviceId != null) {
        final devices = _deviceProvider.getDevices(widget.mode);
        try {
          final updatedDevice = devices.firstWhere(
            (device) => device.id == _selectedDeviceId,
          );
          if (mounted) {
            setState(() {
              _selectedDeviceName = updatedDevice.name;
            });
          }
        } catch (e) {
          // Device not found in the list, keep current name
        }
      }

      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) {
          _checkAndLoadMoreIfNeeded();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _deviceProvider.removeListener(_onDeviceListChanged);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      // Trigger next page when near the end
      if (!_deviceProvider.getLoading(widget.mode)) {
        _deviceProvider.nextPageForMode(widget.mode);
      }
    }
  }

  // Check if viewport has enough items to scroll, if not load more
  void _checkAndLoadMoreIfNeeded() {
    if (!mounted) return;

    // If we have a scroll controller with a position
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      final filterState = _deviceProvider.getFilterState(widget.mode);

      // If list doesn't fill viewport (no scrolling possible)
      if (position.maxScrollExtent <= 0 &&
          filterState.page < filterState.totalPages &&
          !filterState.isNextPageLoading) {
        // Load next page and check again
        _deviceProvider.nextPageForMode(widget.mode).then((_) {
          if (mounted) {
            Future.delayed(
              Duration(milliseconds: 100),
              _checkAndLoadMoreIfNeeded,
            );
          }
        });
      }
    } else {
      // If no clients yet, wait a bit and try again
      Future.delayed(Duration(milliseconds: 100), _checkAndLoadMoreIfNeeded);
    }
  }

  String searchValue = "";

  Future<void> _handleExport() async {
    if (isSpecialMode) return; // No export for rejected/suspended devices

    setState(() => _exportLoading = true);
    try {
      await _deviceProvider.exportDevicesToExcel();
      filledSuccessToast(title: 'فایل اکسل با موفقیت دانلود شد');
    } catch (e) {
      flatErrorToast(
        title: 'خطا در دانلود فایل اکسل',
        description: e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() => _exportLoading = false);
      }
    }
  }

  void _selectDevice(int deviceId, String deviceName) {
    setState(() {
      _selectedDeviceId = deviceId;
      _selectedDeviceName = deviceName;
    });
  }

  void _closeDetailPanel() {
    setState(() {
      _selectedDeviceId = null;
      _selectedDeviceName = null;
    });
  }

  String _getTitle() {
    switch (widget.mode) {
      case DeviceListMode.all:
        return "موتورخانه ها";
      case DeviceListMode.rejected:
        return "موتورخانه های رد شده";
      case DeviceListMode.suspended:
        return "موتورخانه های در حال بررسی";
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    final deviceProvider = context.watch<DeviceProvider>();
    final accessControl = context.watch<UserProvider>().accessControl;
    final canAddDevice = accessControl.hasAccessTo(
      AppPanel.addDeviceFunctionality,
    );
    final devices = deviceProvider.getDevices(widget.mode);
    final screenWidth = MediaQuery.of(context).size.width;

    // Can use split view on screens wider than 1200px
    final bool canUseSplitView = screenWidth > 1200;
    // Actually show split view only when a device is selected
    final bool showSplitView = canUseSplitView && _selectedDeviceId != null;
    // Show column headers when screen is wide AND we're not in split view mode
    final bool showColumnHeaders = screenWidth > 800 && !showSplitView;

    return BackScaffold(
      label: _getTitle(),
      backLabel: "خانه",
      backRoute: "/home",

      //
      // Floating Action Button (only for normal mode + access)
      //
      floatingActionButton: widget.mode == DeviceListMode.all && canAddDevice
          ? AddFloatingButton(addModal: AddDeviceModal())
          : null,

      //
      // Body
      //
      body: showSplitView
          ? _buildSplitView(context, deviceProvider, devices, searchController)
          : _buildNormalView(
              context,
              deviceProvider,
              devices,
              searchController,
              showColumnHeaders,
              canUseSplitView, // Pass this to enable click-to-split behavior
            ),
    );
  }

  /// Build the split view layout for large screens
  Widget _buildSplitView(
    BuildContext context,
    DeviceProvider deviceProvider,
    List<Device> devices,
    TextEditingController searchController,
  ) {
    final isLoading = deviceProvider.getLoading(widget.mode);
    final filterState = deviceProvider.getFilterState(widget.mode);
    final canExport = context.read<UserProvider>().accessControl.hasAccessTo(
      AppPanel.exportFunctionality,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Device List Panel (Right side in RTL) - compact when detail is shown
        Expanded(
          flex: 4,
          child: Column(
            children: [
              // Header
              TabHeader(
                onSubmitted: (value) async {
                  setState(() {
                    searchValue = value;
                  });
                  await deviceProvider.loadDevicesForMode(
                    mode: widget.mode,
                    all: false,
                    page: 1,
                    search: value,
                    installer: filterState.selectedInstaller,
                    organization: filterState.selectedOrg,
                    administration: filterState.selectedAdmin,
                    province: filterState.selectedProvince,
                    city: filterState.selectedCity,
                    plan: filterState.selectedPlan,
                    start: filterState.startDate,
                    end: filterState.endDate,
                  );
                },
                searchController: searchController,
                filterModal: FilterDeviceModal(mode: widget.mode),
                searchPlaceholder: "جستجوی موتورخانه...",
                onExport: isSpecialMode || !canExport ? null : _handleExport,
                exportLoading: _exportLoading,
              ),
              SizedBox(height: 10),

              // Search results indicator
              if (searchValue != "")
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "نتایج جستجو برای موتورخانه ها با نام: $searchValue",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),

              // Active Filters
              if (filterState.filterCount > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildFilterIndicator(context, deviceProvider),
                ),

              // Device List (will automatically use mobile layout due to reduced width)
              Expanded(
                child: isLoading
                    ? Center(child: Loading())
                    : devices.isEmpty
                    ? Center(child: Text("موتورخانه ای یافت نشد."))
                    : _buildDeviceListView(
                        context,
                        deviceProvider,
                        devices,
                        enableSplitViewClick: true,
                        compactMode: true, // Use compact mode in split view
                      ),
              ),
            ],
          ),
        ),

        // Detail Panel (Left side in RTL)
        SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: DeviceDetailPanel(
            key: ValueKey(_selectedDeviceId),
            deviceId: _selectedDeviceId!,
            deviceName: _selectedDeviceName ?? '',
            onClose: _closeDetailPanel,
          ),
        ),
      ],
    );
  }

  /// Build the normal (non-split) view for smaller screens
  Widget _buildNormalView(
    BuildContext context,
    DeviceProvider deviceProvider,
    List<Device> devices,
    TextEditingController searchController,
    bool showColumnHeaders,
    bool
    canUseSplitView, // If true, clicking a device will open split view instead of navigating
  ) {
    final isLoading = deviceProvider.getLoading(widget.mode);
    final filterState = deviceProvider.getFilterState(widget.mode);
    final canExport = context.read<UserProvider>().accessControl.hasAccessTo(
      AppPanel.exportFunctionality,
    );

    return Column(
      children: [
        // Header
        TabHeader(
          onSubmitted: (value) async {
            setState(() {
              searchValue = value;
            });
            await deviceProvider.loadDevicesForMode(
              mode: widget.mode,
              all: false,
              page: 1,
              search: value,
              installer: filterState.selectedInstaller,
              organization: filterState.selectedOrg,
              administration: filterState.selectedAdmin,
              province: filterState.selectedProvince,
              city: filterState.selectedCity,
              plan: filterState.selectedPlan,
              start: filterState.startDate,
              end: filterState.endDate,
            );
          },
          searchController: searchController,
          filterModal: FilterDeviceModal(mode: widget.mode),
          searchPlaceholder: "جستجوی موتورخانه...",
          onExport: isSpecialMode || !canExport ? null : _handleExport,
          exportLoading: _exportLoading,
        ),
        SizedBox(height: 10),

        // Search results
        if (searchValue != "")
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "نتایج جستجو برای موتورخانه ها با نام: $searchValue",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),

        // Active Filters
        if (filterState.filterCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildFilterIndicator(context, deviceProvider),
          ),

        // Column Headers
        if (showColumnHeaders)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildColumnHeaders(context),
          ),

        // Device List
        Expanded(
          child: isLoading
              ? Center(child: Loading())
              : devices.isEmpty
              ? Center(child: Text("موتورخانه ای یافت نشد."))
              : _buildDeviceListView(
                  context,
                  deviceProvider,
                  devices,
                  enableSplitViewClick: canUseSplitView,
                ),
        ),
      ],
    );
  }

  Widget _buildFilterIndicator(
    BuildContext context,
    DeviceProvider deviceProvider,
  ) {
    final filterState = deviceProvider.getFilterState(widget.mode);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "${filterState.filterCount} فیلتر فعال",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              deviceProvider.clearFiltersForMode(widget.mode);
              await deviceProvider.loadDevicesForMode(
                mode: widget.mode,
                all: false,
                page: 1,
                search: searchValue.isEmpty ? null : searchValue,
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "پاک کردن فیلترها",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'نام',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'سازمان',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'نصاب',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'تاریخ نصب',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'شهر',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'پلن',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              isSpecialMode ? 'عملیات' : 'وضعیت',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 40,
            child: Center(
              child: Text(
                'اتصال',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceListView(
    BuildContext context,
    DeviceProvider deviceProvider,
    List<Device> devices, {
    required bool enableSplitViewClick,
    bool compactMode = false,
  }) {
    final filterState = deviceProvider.getFilterState(widget.mode);

    return ListView.builder(
      controller: _scrollController,
      itemCount: filterState.isNextPageLoading
          ? devices.length + 1
          : devices.length,
      itemBuilder: (context, index) {
        if (index == devices.length && filterState.isNextPageLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Loading()),
          );
        }

        final device = devices[index];
        final bool isSelected = _selectedDeviceId == device.id;

        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: DeviceTile(
            deviceId: device.id,
            name: device.name,
            org: device.organization,
            isConnected: device.isConnected,
            color: Theme.of(context).colorScheme.surface,
            isFirst: index == 0,
            installationDate: device.createdAt.replaceAll(" ", " - "),
            latLong: device.latLong,
            address: device.city,
            status: device.status,
            rawStatus: device.rawStatus,
            rejectionNote: device.rejectionNote,
            creator: device.creator,
            plan: device.plan ?? "-",
            isSelected: isSelected,
            compactMode: compactMode,
            showRejectedActions: isSpecialMode,
            showRejectionNote: isRejectedMode,
            onTap: enableSplitViewClick
                ? () => _selectDevice(device.id, device.name)
                : null, // null means use default navigation
          ),
        );
      },
    );
  }
}
