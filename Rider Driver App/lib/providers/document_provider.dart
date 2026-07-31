import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/document_repository.dart';

class DocumentProvider extends ChangeNotifier {
  DocumentProvider(this._repo);

  final DocumentRepository _repo;

  List<DocumentItem> documents = [];
  List<OnboardingStepStatus> steps = [];
  double progress = 0;
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      documents = await _repo.getDocuments();
      steps = await _repo.getOnboardingStatus();
      progress = await _repo.getVerificationProgress();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> upload(String id, String path) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repo.uploadDocument(id, path);
      await load();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitToken({
    required String id,
    required String tokenNumber,
    required String path,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repo.submitTokenEvidence(
        id: id,
        tokenNumber: tokenNumber,
        localPath: path,
      );
      await load();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
