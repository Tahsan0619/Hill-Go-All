import '../services/api/api_client.dart';

/// Returns a short, safe message suitable for UI snackbars / banners.
/// Never exposes raw [Exception.toString] stacks or type dumps.
String userFacingError(Object e) {
  if (e is ApiException) return e.message;
  return 'Something went wrong.';
}
