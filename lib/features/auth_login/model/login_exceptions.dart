/// Domain-layer exceptions for login flows.
/// Controllers & repositories use these to signal typed failures.

abstract class LoginAuthFailure implements Exception {}

class LoginAuthInvalidCredentials extends LoginAuthFailure {}

abstract class LoginNetworkFailure implements Exception {}

class LoginNetworkException extends LoginNetworkFailure {}
