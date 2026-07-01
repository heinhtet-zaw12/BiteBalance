abstract class Failure {
  final String message;

  const Failure(this.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class QuotaExhaustedException implements Exception {
  final String message;
  const QuotaExhaustedException([
    this.message = 'AI analysis is temporarily unavailable. Please try again in a few minutes.',
  ]);

  @override
  String toString() => message;
}

class ServerBusyException implements Exception {
  final String message;
  const ServerBusyException([
    this.message = 'Server is busy. Please try again.',
  ]);

  @override
  String toString() => message;
}
