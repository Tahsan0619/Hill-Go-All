import '../../models/models.dart';
import '../document_repository.dart';
import 'api_client.dart';

/// Rider KYC document endpoints against the HillGo Laravel backend.
class ApiDocumentRepository implements DocumentRepository {
  ApiDocumentRepository(this._client);

  final ApiClient _client;

  static const _descriptions = <String, String>{
    'id_proof': 'If you have a driving license, upload a clear photo. '
        'If you do not have a license, enter your token number and upload the '
        'token paper/photo as evidence.',
    'nid': 'Upload front of your Bangladesh NID card.',
    'registration': 'Upload vehicle registration (blue book) photo.',
    'photo': 'Upload a clear photo of yourself for your rider profile.',
  };

  DocumentItem _mapDoc(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final rawStatus = json['status'] as String? ?? 'pending';
    final token = json['token_number'] as String?;

    // The backend has no sequential locking, so anything not yet uploaded is
    // immediately actionable in the UI.
    final status = switch (rawStatus) {
      'verified' => DocStatus.verified,
      'uploaded' => DocStatus.uploaded,
      _ => DocStatus.actionRequired,
    };

    final subtitle = switch (status) {
      DocStatus.verified => 'Verified',
      DocStatus.uploaded =>
        token != null ? 'Token $token — under review' : 'Uploaded — under review',
      _ => rawStatus == 'rejected' || rawStatus == 'action_required'
          ? 'Action required — upload again'
          : (id == 'id_proof' ? 'Upload license OR token number + photo' : 'Required'),
    };

    return DocumentItem(
      id: id,
      title: json['title'] as String? ?? id,
      status: status,
      subtitle: subtitle,
      tokenNumber: token,
      allowsTokenAlternative: json['allows_token_alternative'] as bool? ?? false,
      description: _descriptions[id],
    );
  }

  @override
  Future<List<DocumentItem>> getDocuments() async {
    final json = await _client.get('/rider/documents') as Map<String, dynamic>;
    return (json['documents'] as List<dynamic>)
        .map((d) => _mapDoc(d as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DocumentItem> uploadDocument(String id, String localPath) async {
    await _client.upload(
      '/rider/documents/$id/upload',
      files: {'file': localPath},
    );
    final docs = await getDocuments();
    return docs.firstWhere((d) => d.id == id);
  }

  @override
  Future<DocumentItem> submitTokenEvidence({
    required String id,
    required String tokenNumber,
    required String localPath,
  }) async {
    await _client.upload(
      '/rider/documents/id_proof/token',
      fields: {'token_number': tokenNumber.trim().toUpperCase()},
      files: {'photo': localPath},
    );
    final docs = await getDocuments();
    return docs.firstWhere((d) => d.id == id);
  }

  @override
  Future<double> getVerificationProgress() async {
    final json = await _client.get('/rider/onboarding/status') as Map<String, dynamic>;
    final uploaded = (json['documents_uploaded'] as num?)?.toDouble() ?? 0;
    final required = (json['documents_required'] as num?)?.toDouble() ?? 1;
    return required <= 0 ? 0 : (uploaded / required).clamp(0.0, 1.0);
  }

  @override
  Future<List<OnboardingStepStatus>> getOnboardingStatus() async {
    final status = await _client.get('/rider/onboarding/status') as Map<String, dynamic>;
    final me = await _client.get('/rider/me') as Map<String, dynamic>;

    final profile = me['profile'] as Map<String, dynamic>?;
    final vehicleDone = profile?['vehicle_make'] != null;
    final uploaded = (status['documents_uploaded'] as num?)?.round() ?? 0;
    final required = (status['documents_required'] as num?)?.round() ?? 4;
    final docsDone = uploaded >= required;
    final kyc = status['kyc_status'] as String? ?? 'pending';
    final verified =
        kyc == 'verified' && (status['account_status'] as String?) == 'active';

    return [
      OnboardingStepStatus(step: 1, label: 'Registration', completed: true),
      OnboardingStepStatus(
        step: 2,
        label: 'Vehicle',
        completed: vehicleDone,
        inProgress: !vehicleDone,
      ),
      OnboardingStepStatus(
        step: 3,
        label: 'Documents',
        completed: docsDone,
        inProgress: vehicleDone && !docsDone,
      ),
      OnboardingStepStatus(
        step: 4,
        label: 'Verification',
        completed: verified,
        inProgress: docsDone && !verified,
      ),
    ];
  }
}
