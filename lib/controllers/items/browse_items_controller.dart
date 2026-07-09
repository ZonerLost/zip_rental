import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/services/items/item_api_service.dart';

class BrowseItemsController extends GetxController {
  BrowseItemsController({ItemApiService? itemApiService})
    : _itemApiService = itemApiService ?? ItemApiService();

  final ItemApiService _itemApiService;

  final List<ItemModel> items = <ItemModel>[];

  // Feed sections
  List<ItemModel> nearMe = const [];
  List<ItemModel> popular = const [];
  List<ItemModel> recent = const [];
  bool isFeedLoading = false;
  String? feedError;

  // User coordinates for feed
  double? userLat;
  double? userLng;

  bool isLoadingInitial = false;
  bool isLoadingMore = false;
  bool isRefreshing = false;
  String? errorMessage;

  int _page = 1;
  final int _limit = 10;
  bool hasNext = true;

  String? category;
  String? city;
  double? minPrice;
  double? maxPrice;
  String? condition;
  String? search;
  String? sortBy;
  String? sortOrder;
  double? distance;

  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    loadItems(reset: true);
    loadFeed();
  }

  Future<void> loadFeed() async {
    isFeedLoading = true;
    feedError = null;
    update();

    final result = await _itemApiService.getFeed(
      lat: userLat,
      lng: userLng,
    );

    isFeedLoading = false;
    if (result.success) {
      nearMe = result.nearMe;
      popular = result.popular;
      recent = result.recent;
      feedError = null;
    } else {
      feedError = result.message;
    }
    update();
  }

  Future<void> loadItems({bool reset = false}) async {
    if (reset) {
      _page = 1;
      hasNext = true;
      items.clear();
      errorMessage = null;
      isLoadingInitial = true;
      update();
    } else {
      if (isLoadingMore || !hasNext || isLoadingInitial) {
        return;
      }
      isLoadingMore = true;
      update();
    }

    final result = await _itemApiService.browseItems(
      page: _page,
      limit: _limit,
      category: category,
      city: city,
      minPrice: minPrice,
      maxPrice: maxPrice,
      condition: condition,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
      distance: distance,
    );

    if (!result.success) {
      errorMessage = result.message;
      isLoadingInitial = false;
      isLoadingMore = false;
      isRefreshing = false;
      update();
      return;
    }

    if (reset) {
      items
        ..clear()
        ..addAll(result.items);
    } else {
      items.addAll(result.items);
    }

    final pagination = result.pagination;
    if (pagination != null) {
      hasNext = pagination.hasNext;
      _page = pagination.page + 1;
    } else {
      hasNext = result.items.length >= _limit;
      _page += 1;
    }

    errorMessage = null;
    isLoadingInitial = false;
    isLoadingMore = false;
    isRefreshing = false;
    update();
  }

  Future<void> refreshItems() async {
    isRefreshing = true;
    update();
    await loadItems(reset: true);
  }

  void setSearchQuery(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      final trimmed = value.trim();
      if ((search ?? '') == trimmed) {
        return;
      }
      search = trimmed.isEmpty ? null : trimmed;
      loadItems(reset: true);
    });
  }

  void applyFilters({
    String? categoryValue,
    String? cityValue,
    double? minPriceValue,
    double? maxPriceValue,
    String? conditionValue,
    String? sortByValue,
    String? sortOrderValue,
    double? distanceValue,
  }) {
    category = _normalized(categoryValue);
    city = _normalized(cityValue);
    minPrice = minPriceValue;
    maxPrice = maxPriceValue;
    condition = _normalized(conditionValue);
    sortBy = _normalized(sortByValue);
    sortOrder = _normalized(sortOrderValue);
    distance = distanceValue;

    loadItems(reset: true);
  }

  /// Unique non-empty categories extracted from loaded feed items.
  List<String> get feedCategories {
    final all = [...nearMe, ...popular, ...recent];
    final seen = <String>{};
    return all
        .map((i) => i.category ?? '')
        .where((c) => c.isNotEmpty && seen.add(c))
        .toList(growable: false);
  }

  bool get hasActiveFilters =>
      (category?.isNotEmpty == true) || (city?.isNotEmpty == true);

  void clearFilters() {
    category = null;
    city = null;
    minPrice = null;
    maxPrice = null;
    condition = null;
    sortBy = null;
    sortOrder = null;
    distance = null;
    loadItems(reset: true);
  }

  /// Called by a screen's own [ScrollController] listener to trigger
  /// pagination once the user nears the bottom of that screen's list.
  /// Each screen must own its ScrollController — a single controller cannot
  /// be attached to more than one scroll view at a time.
  void maybeLoadMore(ScrollMetrics metrics) {
    if (metrics.pixels >= metrics.maxScrollExtent - 240) {
      unawaited(loadItems());
    }
  }

  String? _normalized(String? value) {
    final trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }
}
