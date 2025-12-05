import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Performance optimization utilities
class PerformanceOptimizer {
  static final Map<String, Timer> _debounceTimers = {};
  static final Map<String, DateTime> _throttleTimers = {};
  static final Queue<DateTime> _memoryCheckpoints = Queue<DateTime>();

  /// Debounce function calls to prevent excessive execution
  static void debounce(String key, VoidCallback callback, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, () {
      callback();
      _debounceTimers.remove(key);
    });
  }

  /// Throttle function calls to limit execution frequency
  static bool throttle(String key, {Duration delay = const Duration(milliseconds: 500)}) {
    final now = DateTime.now();
    final lastCall = _throttleTimers[key];
    
    if (lastCall == null || now.difference(lastCall) >= delay) {
      _throttleTimers[key] = now;
      return true;
    }
    
    return false;
  }

  /// Clear all timers
  static void clearTimers() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _throttleTimers.clear();
  }

  /// Memory management utilities
  static void addMemoryCheckpoint() {
    _memoryCheckpoints.add(DateTime.now());
    
    // Keep only last 10 checkpoints
    if (_memoryCheckpoints.length > 10) {
      _memoryCheckpoints.removeFirst();
    }
  }

  /// Check memory usage (simplified)
  static void checkMemoryUsage() {
    addMemoryCheckpoint();
    
    if (kDebugMode) {
      print('Memory checkpoints: ${_memoryCheckpoints.length}');
    }
  }

  /// Optimize list rendering
  static List<T> optimizeList<T>(List<T> list, {int maxItems = 100}) {
    if (list.length <= maxItems) return list;
    return list.take(maxItems).toList();
  }

  /// Optimize image loading
  static String optimizeImageUrl(String url, {int width = 300, int height = 300}) {
    // Add image optimization parameters
    final uri = Uri.parse(url);
    final optimizedUri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      'w': width.toString(),
      'h': height.toString(),
      'q': '80', // Quality
      'f': 'auto', // Format
    });
    return optimizedUri.toString();
  }
}

/// Lazy loading utility
class LazyLoader<T> {
  final Future<List<T>> Function(int page, int limit) loadFunction;
  final int limit;
  
  List<T> _items = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  LazyLoader({
    required this.loadFunction,
    this.limit = 20,
  });

  List<T> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  /// Load next page
  Future<void> loadNext() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    try {
      final newItems = await loadFunction(_currentPage, limit);
      
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(newItems);
        _currentPage++;
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    _items.clear();
    _currentPage = 0;
    _hasMore = true;
    await loadNext();
  }

  /// Clear all data
  void clear() {
    _items.clear();
    _currentPage = 0;
    _hasMore = true;
    _isLoading = false;
  }
}

/// Cache manager for performance optimization
class CacheManager {
  static final Map<String, CacheEntry> _cache = {};
  static const Duration defaultExpiry = Duration(minutes: 30);

  /// Get cached data
  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// Set cached data
  static void set<T>(String key, T data, {Duration? expiry}) {
    _cache[key] = CacheEntry(
      data: data,
      expiry: expiry ?? defaultExpiry,
    );
  }

  /// Remove cached data
  static void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cache
  static void clear() {
    _cache.clear();
  }

  /// Clear expired entries
  static void clearExpired() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// Get cache size
  static int get size => _cache.length;
}

/// Cache entry class
class CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  final Duration expiry;

  CacheEntry({
    required this.data,
    required this.expiry,
  }) : createdAt = DateTime.now();

  bool get isExpired => DateTime.now().difference(createdAt) > expiry;
}

/// Image optimization utilities
class ImageOptimizer {
  /// Get optimized image dimensions
  static Size getOptimizedSize(Size originalSize, {double maxWidth = 300, double maxHeight = 300}) {
    if (originalSize.width <= maxWidth && originalSize.height <= maxHeight) {
      return originalSize;
    }

    final aspectRatio = originalSize.width / originalSize.height;
    
    if (originalSize.width > originalSize.height) {
      return Size(maxWidth, maxWidth / aspectRatio);
    } else {
      return Size(maxHeight * aspectRatio, maxHeight);
    }
  }

  /// Generate placeholder image URL
  static String generatePlaceholder({int width = 300, int height = 300, String text = 'Image'}) {
    return 'https://via.placeholder.com/${width}x${height}/f0f0f0/999999?text=$text';
  }
}

/// Network optimization utilities
class NetworkOptimizer {
  static final Map<String, CancelToken> _requests = {};

  /// Cancel ongoing request
  static void cancelRequest(String key) {
    _requests[key]?.cancel();
    _requests.remove(key);
  }

  /// Cancel all requests
  static void cancelAllRequests() {
    for (final token in _requests.values) {
      token.cancel();
    }
    _requests.clear();
  }

  /// Add request token
  static void addRequest(String key, CancelToken token) {
    _requests[key] = token;
  }

  /// Remove request token
  static void removeRequest(String key) {
    _requests.remove(key);
  }
}

/// Cancel token for network requests
class CancelToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }

  void throwIfCancelled() {
    if (_isCancelled) {
      throw Exception('Request was cancelled');
    }
  }
}

/// Widget performance utilities
class WidgetPerformance {
  /// Create optimized list view
  static Widget createOptimizedListView<T>({
    required List<T> items,
    required Widget Function(BuildContext context, T item, int index) itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index], index);
      },
    );
  }

  /// Create optimized grid view
  static Widget createOptimizedGridView<T>({
    required List<T> items,
    required Widget Function(BuildContext context, T item, int index) itemBuilder,
    required int crossAxisCount,
    double childAspectRatio = 1.0,
    ScrollController? controller,
  }) {
    return GridView.builder(
      controller: controller,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index], index);
      },
    );
  }
}

/// Memory management utilities
class MemoryManager {
  static final List<StreamSubscription> _subscriptions = [];
  static final List<Timer> _timers = [];

  /// Add subscription for cleanup
  static void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Add timer for cleanup
  static void addTimer(Timer timer) {
    _timers.add(timer);
  }

  /// Cleanup all resources
  static void cleanup() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    CacheManager.clearExpired();
    PerformanceOptimizer.clearTimers();
  }
}
