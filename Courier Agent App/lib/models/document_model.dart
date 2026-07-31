/// A KYC document slot as returned by `GET /courier/documents`.
class CourierDocument {
  const CourierDocument({
    required this.key,
    required this.title,
    required this.status,
    required this.uploaded,
    this.expiresAt,
  });

  factory CourierDocument.fromJson(Map<String, dynamic> json) => CourierDocument(
    key: '${json['id']}',
    title: (json['title'] as String?) ?? '',
    status: (json['status'] as String?) ?? 'pending',
    uploaded: json['uploaded'] == true || (json['uploaded'] is String && (json['uploaded'] as String).isNotEmpty),
    expiresAt: json['expires_at'] is String ? DateTime.tryParse(json['expires_at'] as String) : null,
  );

  final String key;
  final String title;

  /// `pending`, `uploaded`, `verified`, or `rejected`.
  final String status;
  final bool uploaded;
  final DateTime? expiresAt;
}
