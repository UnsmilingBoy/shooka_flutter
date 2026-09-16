import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/models/app_panel.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';

/// Flowchart / process-steps section of the device page.
///
/// Permission-gated by [AppPanel.flowchart]. When the user has no access,
/// renders nothing ([SizedBox.shrink]).
///
/// Works for both mobile ([device_page.dart]) and desktop
/// ([device_detail_panel.dart]) — vertical timeline layout is responsive.
class DpFlowchart extends StatefulWidget {
  const DpFlowchart({super.key});

  @override
  State<DpFlowchart> createState() => _DpFlowchartState();
}

class _DpFlowchartState extends State<DpFlowchart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final hasAccess = context
          .read<UserProvider>()
          .accessControl
          .hasAccessTo(AppPanel.flowchart);
      if (!hasAccess) return;
      final provider = context.read<DeviceProvider>();
      if (provider.flowchartItems.isEmpty &&
          !provider.flowchartLoading) {
        provider.loadFlowchartItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasAccess = context
        .watch<UserProvider>()
        .accessControl
        .hasAccessTo(AppPanel.flowchart);
    if (!hasAccess) return const SizedBox.shrink();

    final provider = context.watch<DeviceProvider>();
    final items = provider.flowchartItems;
    final loading = provider.flowchartLoading;
    final error = provider.flowchartError;

    return MyExpansionTile(
      initiallyExpanded: true,
      title: "مراحل انجام کار",
      children: [
        if (loading && items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40.0),
            child: Loading(),
          )
        else if (error != null && items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text("خطا در دریافت مراحل انجام کار."),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context
                      .read<DeviceProvider>()
                      .loadFlowchartItems(forceRefresh: true),
                  child: const Text("تلاش مجدد"),
                ),
              ],
            ),
          )
        else if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "مرحله‌ای یافت نشد.",
              style: Theme.of(context).textTheme.labelSmall,
            ),
          )
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isLast = index == items.length - 1;
              final isActive = item.isActive;
              final colorScheme = Theme.of(context).colorScheme;
              final stepColor = isActive
                  ? Colors.green
                  : colorScheme.outline.withOpacity(0.6);

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? Colors.green.withOpacity(0.15)
                                : colorScheme.surfaceContainerHighest,
                            border: Border.all(color: stepColor, width: 1.5),
                          ),
                          child: Center(
                            child: isActive
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.green,
                                  )
                                : Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: stepColor,
                                    ),
                                  ),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: stepColor.withOpacity(0.4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Step content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green.withOpacity(0.15)
                                        : Colors.grey.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isActive
                                          ? Colors.green
                                          : Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    isActive ? "فعال" : "غیرفعال",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (item.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  item.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.apply(
                                        color: Theme.of(context).hintColor,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
