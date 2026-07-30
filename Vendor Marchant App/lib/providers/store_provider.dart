import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/store_model.dart';
import '../services/mock/mock_data_repositories.dart';

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

  // Settings
  bool notifyNewOrders = true;
  bool notifyPayouts = true;
  bool notifyReviews = false;
  String language = 'English (United States)';

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      store = await _repo.getStore();
      reviews = await _repo.getReviews();
      payouts = await _repo.getPayouts();
      transactions = await _repo.getTransactions();
      revenueSummary = await _repo.getRevenueSummary();
      revenueTrend = await _repo.getRevenueTrend(trendPeriod);
      notifyNewOrders = _prefs.getBool('notify_orders') ?? true;
      notifyPayouts = _prefs.getBool('notify_payouts') ?? true;
      notifyReviews = _prefs.getBool('notify_reviews') ?? false;
      language = _prefs.getString('language') ?? 'English (United States)';
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
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
    revenueTrend = await _repo.getRevenueTrend(period);
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
    } catch (_) {
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
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestEarlyPayout() async {
    isSaving = true;
    notifyListeners();
    try {
      await _repo.requestEarlyPayout();
      isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setNotifyNewOrders(bool v) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    notifyNewOrders = v;
    await _prefs.setBool('notify_orders', v);
    notifyListeners();
  }

  Future<void> setNotifyPayouts(bool v) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    notifyPayouts = v;
    await _prefs.setBool('notify_payouts', v);
    notifyListeners();
  }

  Future<void> setNotifyReviews(bool v) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    notifyReviews = v;
    await _prefs.setBool('notify_reviews', v);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    language = lang;
    await _prefs.setString('language', lang);
    notifyListeners();
  }

  void toggleStoreOpen(bool open) {
    store?.isOpen = open;
    notifyListeners();
  }

  void toggleAcceptingOrders(bool v) {
    store?.acceptingOrders = v;
    notifyListeners();
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
