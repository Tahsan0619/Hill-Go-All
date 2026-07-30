import '../models/models.dart';

abstract class DocumentRepository {
  Future<List<DocumentItem>> getDocuments();
  Future<DocumentItem> uploadDocument(String id, String localPath);
  Future<DocumentItem> submitTokenEvidence({
    required String id,
    required String tokenNumber,
    required String localPath,
  });
  Future<double> getVerificationProgress();
  Future<List<OnboardingStepStatus>> getOnboardingStatus();
}

class OnboardingStepStatus {
  OnboardingStepStatus({
    required this.step,
    required this.label,
    required this.completed,
    this.inProgress = false,
  });

  final int step;
  final String label;
  final bool completed;
  final bool inProgress;
}
