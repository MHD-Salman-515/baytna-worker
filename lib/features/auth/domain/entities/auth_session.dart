import 'package:baytna_worker/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

/// Result of a successful OTP verification. Tokens are deliberately absent:
/// they are persisted by the data layer and never travel through blocs.
class AuthSession extends Equatable {
  const AuthSession({required this.user, required this.isNewUser});

  final User user;

  /// True on first login — later this routes to profile completion.
  final bool isNewUser;

  @override
  List<Object?> get props => [user, isNewUser];
}
