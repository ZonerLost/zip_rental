import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/items/browse_items_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/views/screens/home/home_widgets.dart';
import 'package:zip_peer/views/screens/home/item_detail/add_item.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/double_white_contianers.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

// Fallback center used until the device location is known / if permission
// is denied, so the map never opens on the (0, 0) null-island default.
const LatLng _kFallbackCenter = LatLng(43.6532, -79.3832);

class HomeExploreScreen extends StatefulWidget {
  const HomeExploreScreen({super.key});

  @override
  State<HomeExploreScreen> createState() => _HomeExploreScreenState();
}

class _HomeExploreScreenState extends State<HomeExploreScreen> {
  late final BrowseItemsController _browseController;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng _center = _kFallbackCenter;
  bool _locatingUser = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _browseController = Get.isRegistered<BrowseItemsController>()
        ? Get.find<BrowseItemsController>()
        : Get.put(BrowseItemsController());
    _resolveUserLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _resolveUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locatingUser = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _locatingUser = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (!mounted) return;

      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _locatingUser = false;
      });
      _mapController.move(_center, 13);

      _browseController.userLat = position.latitude;
      _browseController.userLng = position.longitude;
      _browseController.loadFeed();
    } catch (_) {
      if (mounted) {
        setState(() => _locatingUser = false);
      }
    }
  }

  List<ItemModel> _itemsWithCoordinates(List<ItemModel> items) {
    return items
        .where((item) =>
            item.location?.coordinates?.lat != null &&
            item.location?.coordinates?.lng != null)
        .toList(growable: false);
  }

  List<ItemModel> _applySearch(List<ItemModel> items) {
    if (_searchQuery.isEmpty) return items;
    final query = _searchQuery.toLowerCase();
    return items
        .where((item) => (item.title ?? '').toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrowseItemsController>(
      init: _browseController,
      builder: (controller) {
        final mappable = _itemsWithCoordinates(controller.nearMe);
        final visible = _applySearch(mappable);

        return Scaffold(
          body: Column(
            children: [
              const Gap(50),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Bounce(
                          onTap: () {
                            Get.back();
                          },
                          child: CommonImageView(
                            imagePath: Assets.imagesBack,
                            height: 50,
                          ),
                        ),
                        MyText(
                          text: "Explore on Map",
                          size: 16,
                          color: kBlack,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                    const Gap(10),
                    MyTextField(
                      controller: _searchController,
                      marginBottom: 0,
                      backgroundColor: kWhite,
                      hint: "Search nearby items",
                      hintColor: kSubText2,
                      isObSecure: false,
                      radius: 25,
                      hintsize: 12,
                      hintWeight: FontWeight.w400,
                      onChanged: (value) {
                        setState(() => _searchQuery = value.trim());
                      },
                      suffix: CommonImageView(
                        imagePath: Assets.imagesMynauiSearch,
                        height: 20,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Stack(
                  children: [
                    /// REAL INTERACTIVE MAP
                    Positioned.fill(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _center,
                          initialZoom: 13,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.zip.peer',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _center,
                                width: 40,
                                height: 40,
                                child: CommonImageView(
                                  imagePath: Assets.imagesLocation,
                                  height: 40,
                                ),
                              ),
                              ...visible.map((item) {
                                final coords = item.location!.coordinates!;
                                return Marker(
                                  point: LatLng(coords.lat!, coords.lng!),
                                  width: 42,
                                  height: 42,
                                  child: Bounce(
                                    onTap: () =>
                                        Get.to(() => ItemDetailsScreen(
                                              itemId: item.id,
                                            )),
                                    child: CommonImageView(
                                      imagePath: Assets.imagesMapPin,
                                      height: 42,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (_locatingUser)
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: MyText(
                              text: "Locating you...",
                              size: 12,
                              color: kSubText2,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    /// WHITE BOTTOM SHEET
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Builder(builder: (context) {
                        final isEmpty =
                            !controller.isFeedLoading && visible.isEmpty;
                        final sheetHeight = isEmpty ? 180.0 : 430.0;
                        final listHeight = isEmpty ? 60.0 : 310.0;

                        return AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          alignment: Alignment.bottomCenter,
                          child: DoubleWhiteContainers(
                            height: sheetHeight,
                            mainColor: kWhite3,
                            topColor: kWhite,
                            handleHeight: 14,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),

                            /// HORIZONTAL LIST OF NEARBY ITEMS
                            child: SizedBox(
                              height: listHeight,
                              child: controller.isFeedLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : isEmpty
                                      ? Center(
                                          child: MyText(
                                            text: _searchQuery.isNotEmpty
                                                ? "No items match your search"
                                                : "No items found nearby",
                                            size: 14,
                                            color: kSubText2,
                                            weight: FontWeight.w500,
                                          ),
                                        )
                                      : ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          itemCount: visible.length,
                                          itemBuilder: (context, index) {
                                            final item = visible[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 15,
                                              ),
                                              child: Bounce(
                                                onTap: () => Get.to(
                                                  () => ItemDetailsScreen(
                                                    itemId: item.id,
                                                  ),
                                                ),
                                                child: SneakerCard(
                                                  itemId: item.id,
                                                  title:
                                                      item.title ?? 'Untitled',
                                                  price:
                                                      '${item.dailyRate?.toStringAsFixed(2) ?? '0.00'}/day',
                                                  imageUrl: item.thumbnailUrl
                                                          .isNotEmpty
                                                      ? item.thumbnailUrl
                                                      : Assets.imagesShoes1,
                                                  userName: item.ownerName,
                                                  avatarUrl: (item.owner
                                                                  ?.profilePhoto ??
                                                              '')
                                                          .isNotEmpty
                                                      ? item
                                                          .owner!.profilePhoto!
                                                      : Assets
                                                          .imagesChatAvatar,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
