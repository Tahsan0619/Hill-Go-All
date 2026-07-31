import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/store_model.dart';
import '../services/api/api_client.dart';
import '../services/repositories.dart';

class StoreProvider extends ChangeNotifier {
  StoreProvider(this._repo, this._prefs);

  final StoreRepository _repo;
  final SharedPreferences _prefs;

  StoreModel? store;
  List<ReviewModel> reviews = [];
  List<PayoutModel> payouts = [];
  List<TransactionModel> transactions = [];
  Map<String, dynamic> revenueSummary = {};
  List<double> revenueTrend = [];
  String trendPeriod = 'Daily';
  String payoutFilter = 'All Time';
  String reviewFilter = 'All Reviews';
  bool isLoading = false;
  bool isSaving = false;
  String? error;

  /// True when the backend has no store for this merchant yet
  /// (onboarding submitted but not approved).
  bool storePending = false;

  // Settings (mirrors of backend prefs, cached locally for instant UI).
  bool notifyNewOrders = true;
  bool notifyPayouts = true;
  bool notifyReviews = false;
  String language = 'English';

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    notifyNewOrders = _prefs.getBool('notify_orders') ?? true;
    notifyPayouts = _prefs.getBool('notify_payouts') ?? true;
    notifyReviews = _prefs.getBool('notify_reviews') ?? false;
    language = _prefs.getString('language') ?? 'English';

    try {
      store = await _repo.getStore();
      storePending = false;
    } on ApiException catch (e) {
      if (e.isNotFound) {
        // No store yet: onboarding is still under review.
        store = null;
        storePending = true;
        reviews = [];
        payouts = [];
        transactions = [];
        revenueSummary = {};
        revenueTrend = [];
        isLoading = false;
        notifyListeners();
        return;
      }
      error = e.message;
      isLoading = false;
      notifyListeners();
      return;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      reviews = await _repo.getReviews();
      payouts = await _repo.getPayouts();
      transactions = await _repo.getTransactions();
      revenueSummary = await _repo.getRevenueSummary();
      revenueTrend = await _repo.getRevenueTrend(trendPeriod);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  List<ReviewModel> get filteredReviews {
    switch (reviewFilter) {
      case 'Unreplied':
        return reviews.where((r) => !r.hasReply).toList();
      case 'Positive':
        return reviews.where((r) => r.rating >= 4).toList();
      default:
        return reviews;
    }
  }

  List<PayoutModel> get filteredPayouts {
    final now = DateTime.now();
    switch (payoutFilter) {
      case 'Last 30 Days':
        return payouts
            .where((p) => p.date.isAfter(now.subtract(const Duration(days: 30))))
            .toList();
      case 'Last 3 Months':
        return payouts
            .where((p) => p.date.isAfter(now.subtract(const Duration(days: 90))))
            .toList();
      default:
        return payouts;
    }
  }

  double get totalWithdrawn => payouts
      .where((p) => p.status == PayoutStatus.completed)
      .fold(0.0, (s, p) => s + p.amount);

  ReviewModel? findReview(String id) {
    try {
      return reviews.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> setTrendPeriod(String period) async {
    trendPeriod = period;
    notifyListeners();
    try {
      revenueTrend = await _repo.getRevenueTrend(period);
    } catch (_) {
      revenueTrend = [];
    }
    notifyListeners();
  }

  void setPayoutFilter(String f) {
    payoutFilter = f;
    notifyListeners();
  }

  void setReviewFilter(String f) {
    reviewFilter = f;
    notifyListeners();
  }

  Future<bool> saveStore(StoreModel updated) async {
    isSaving = true;
    notifyListeners();
    try {
      store = await _repo.saveStore(updated);
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> replyToReview(String id, String reply) async {
    isSaving = true;
    notifyListeners();
    try {
      await _repo.replyToReview(id, reply);
      reviews = await _repo.getReviews();
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestEarlyPayout({
    required double amount,
    required String method,
  }) async {
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      await _repo.requestEarlyPayout(amount: amount, method: method);
      payouts = await _repo.getPayouts();
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setNotifyNewOrders(bool v) async {
    notifyNewOrders = v;
    await _prefs.setBool('notify_orders', v);
    notifyListeners();
    _pushSettings({'notify_new_orders': v});
  }

  Future<void> setNotifyPayouts(bool v) async {
    notifyPayouts = v;
    await _prefs.setBool('notify_payouts', v);
    notifyListeners();
    _pushSettings({'notify_payouts': v});
  }

  Future<void> setNotifyReviews(bool v) async {
    notifyReviews = v;
    await _prefs.setBool('notify_reviews', v);
    notifyListeners();
    _pushSettings({'notify_reviews': v});
  }

  Future<void> setLanguage(String lang) async {
    language = lang;
    await _prefs.setString('language', lang);
    notifyListeners();
    _pushSettings({'language': lang == 'বাংলা (Bangla)' ? 'bn' : 'en'});
  }

  Future<void> _pushSettings(Map<String, dynamic> settings) async {
    try {
      await _repo.updateSettings(settings);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> toggleStoreOpen(bool open) async {
    final s = store;
    if (s == null) return false;
    final previous = s.isOpen;
    s.isOpen = open;
    notifyListeners();
    try {
      await _repo.setStoreStatus(isOpen: open);
      return true;
    } catch (e) {
      s.isOpen = previous;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleAcceptingOrders(bool v) async {
    final s = store;
    if (s == null) return false;
    final previous = s.acceptingOrders;
    s.acceptingOrders = v;
    notifyListeners();
    try {
      await _repo.setStoreStatus(acceptingOrders: v);
      return true;
    } catch (e) {
      s.acceptingOrders = previous;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void resetHoursToDefault() {
    if (store == null) return;
    for (final day in store!.hours.keys) {
      store!.hours[day] = BusinessHours(
        open: const TimeOfDay(hour: 8, minute: 0),
        close: const TimeOfDay(hour: 20, minute: 0),
        isClosed: day == 'Sunday',
      );
    }
    notifyListeners();
  }

  void touch() => notifyListeners();
}
