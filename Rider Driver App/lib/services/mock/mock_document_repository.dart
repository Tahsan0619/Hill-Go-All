import 'dart:math';

import '../../models/models.dart';
import '../document_repository.dart';

class MockDocumentRepository implements DocumentRepository {
  MockDocumentRepository() {
    _docs = [
      DocumentItem(
        id: 'id_proof',
        title: "Driver's License or Token",
        status: DocStatus.actionRequired,
        subtitle: 'Upload license OR token number + photo',
        description:
            'If you have a driving license, upload a clear photo. '
            'If you do not have a license, enter your token number and upload the token paper/photo as evidence.',
        allowsTokenAlternative: true,
      ),
      DocumentItem(
        id: 'nid',
        title: 'National ID (NID)',
        status: DocStatus.pending,
        subtitle: 'Required',
        description: 'Upload front of your Bangladesh NID card.',
      ),
      DocumentItem(
        id: 'registration',
        title: 'Vehicle Registration',
        status: DocStatus.pending,
        subtitle: 'Blue book / registration paper',
        description: 'Upload vehicle registration (blue book) photo.',
      ),
      DocumentItem(
        id: 'photo',
        title: 'Rider Photo',
        status: DocStatus.pending,
        subtitle: 'Clear face photo',
        description: 'Upload a clear photo of yourself for your rider profile.',
      ),
    ];
  }

  late List<DocumentItem> _docs;
  final _random = Random();

  Duration get _latency => Duration(milliseconds: 400 + _random.nextInt(600));

  @override
  Future<List<DocumentItem>> getDocuments() async {
    await Future.delayed(_latency);
    return List.from(_docs);
  }

  @override
  Future<DocumentItem> uploadDocument(String id, String localPath) async {
    await Future.delayed(_latency);
    final doc = _docs.firstWhere((d) => d.id == id);
    doc.localPath = localPath;
    doc.tokenNumber = null;
    doc.status = DocStatus.uploaded;
    doc.subtitle = id == 'id_proof'
        ? 'License uploaded — under review'
        : 'Uploaded — under review';
    _unlockNext(doc.id);
    return doc;
  }

  @override
  Future<DocumentItem> submitTokenEvidence({
    required String id,
    required String tokenNumber,
    required String localPath,
  }) async {
    await Future.delayed(_latency);
    final cleaned = tokenNumber.trim();
    if (cleaned.length < 4) {
      throw Exception('Enter a valid token number.');
    }
    final doc = _docs.firstWhere((d) => d.id == id);
    if (!doc.allowsTokenAlternative) {
      throw Exception('Token is not accepted for this document.');
    }
    doc.localPath = localPath;
    doc.tokenNumber = cleaned.toUpperCase();
    doc.status = DocStatus.uploaded;
    doc.subtitle = 'Token ${doc.tokenNumber} + photo — under review';
    _unlockNext(doc.id);
    return doc;
  }

  void _unlockNext(String uploadedId) {
    // After ID proof, unlock NID; after NID unlock registration; etc.
    if (uploadedId == 'id_proof') {
      final nid = _docs.firstWhere((d) => d.id == 'nid');
      if (nid.status == DocStatus.pending) {
        nid.status = DocStatus.actionRequired;
        nid.subtitle = 'Action Required';
      }
    } else if (uploadedId == 'nid') {
      final reg = _docs.firstWhere((d) => d.id == 'registration');
      if (reg.status == DocStatus.pending) {
        reg.status = DocStatus.actionRequired;
        reg.subtitle = 'Action Required';
      }
    } else if (uploadedId == 'registration') {
      final photo = _docs.firstWhere((d) => d.id == 'photo');
      if (photo.status == DocStatus.pending) {
        photo.status = DocStatus.actionRequired;
        photo.subtitle = 'Action Required';
      }
    }
  }

  @override
  Future<double> getVerificationProgress() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final done = _docs
        .where((d) => d.status == DocStatus.verified || d.status == DocStatus.uploaded)
        .length;
    return done / _docs.length;
  }

  @override
  Future<List<OnboardingStepStatus>> getOnboardingStatus() async {
    await Future.delayed(_latency);
    final idDone = _docs.any(
      (d) =>
          d.id == 'id_proof' &&
          (d.status == DocStatus.uploaded || d.status == DocStatus.verified),
    );
    return [
      OnboardingStepStatus(step: 1, label: 'Registration', completed: true),
      OnboardingStepStatus(step: 2, label: 'Documents', completed: idDone, inProgress: !idDone),
      OnboardingStepStatus(step: 3, label: 'Vehicle', completed: true),
      OnboardingStepStatus(step: 4, label: 'Verification', completed: false, inProgress: idDone),
    ];
  }
}
