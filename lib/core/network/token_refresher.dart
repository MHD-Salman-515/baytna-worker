import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/network/error_mapper.dart';
import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/core/network/session_events.dart';
import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Name of the bare Dio used only for POST /auth/refresh (no auth/refresh
/// interceptors, so refreshing can never recurse into itself).
const refreshDioName = 'refreshDio';

/// SINGLE-FLIGHT token refresh.
///
/// Refresh tokens rotate on every use and the backend has reuse detection:
/// presenting an already-rotated refresh token revokes EVERY session of the
/// user. So at most one POST /auth/refresh may ever be in flight. Every caller
/// that needs a refresh while one is running receives the same Future, and
/// `AuthInterceptor` parks new requests until it settles.
@lazySingleton
class TokenRefresher {
  TokenRefresher(
    this._storage,
    @Named(refreshDioName) this._dio,
    this._sessionEvents,
  );

  final TokenStorage _storage;
  final Dio _dio;
  final SessionEvents _sessionEvents;

  Future<AuthTokens>? _inFlight;

  bool get isRefreshing => _inFlight != null;

  /// Starts a refresh, or joins the one already running.
  ///
  /// Throws [SessionExpiredFailure] when the server rejects the refresh token
  /// (tokens are cleared and [SessionEvents] notified), or a transient
  /// [Failure] (network/timeout/5xx) when the outcome is unknown — tokens are
  /// then kept, because logging out over a flaky connection would be wrong.
  Future<AuthTokens> refresh() =>
      _inFlight ??= _refresh().whenComplete(() => _inFlight = null);

  /// Completes when no refresh is running. Never throws: callers re-read the
  /// token store afterwards and act on whatever is (or isn't) there.
  Future<void> waitForPendingRefresh() async {
    final pending = _inFlight;
    if (pending == null) return;
    try {
      await pending;
    } on Object catch (_) {
      // The caller that triggered the refresh handles its failure.
    }
  }

  Future<AuthTokens> _refresh() async {
    final current = await _storage.read();
    if (current == null) {
      await _expire();
      throw const SessionExpiredFailure('No refresh token stored');
    }

    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        '/auth/refresh',
        data: {'refreshToken': current.refreshToken},
      );
    } on DioException catch (e) {
      final failure = ErrorMapper.map(e);
      // A definitive rejection (expired, revoked, reused, malformed): the
      // session is dead. Anything else is transient — keep the tokens.
      if (failure is ValidationFailure || failure is UnauthorizedFailure) {
        await _expire();
        throw SessionExpiredFailure(failure.debugMessage);
      }
      throw failure;
    }

    final tokens = AuthTokens.fromJson(asJson(response.data));
    // Persist BEFORE releasing waiters, so every replayed request (and a
    // crash right now) sees the rotated pair, never the spent one.
    await _storage.save(tokens);
    return tokens;
  }

  Future<void> _expire() async {
    await _storage.clear();
    _sessionEvents.notifyExpired();
  }
}
