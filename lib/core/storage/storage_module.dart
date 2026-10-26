import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@module
abstract class StorageModule {
  /// Keychain on iOS/macOS, Keystore-backed on Android. On web the plugin
  /// encrypts with WebCrypto before writing to localStorage — better than
  /// plaintext, but a browser is never as strong as a device keystore.
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
