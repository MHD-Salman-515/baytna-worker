import 'package:dio/dio.dart';

/// Prepares [options] to be sent again. A `FormData` body is single-use (Dio
/// finalizes it while streaming), so a replayed multipart upload needs a
/// fresh copy or Dio throws "FormData has already been finalized".
void replayableBody(RequestOptions options) {
  final data = options.data;
  if (data is FormData) options.data = data.clone();
}
