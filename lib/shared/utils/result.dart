// Placeholder Result type (T004). Implementation to follow in later task.
// Using sealed class structure once Dart 3 sealed support.

sealed class Result<E, T> {
  const Result();
  bool get isSuccess => this is Success<E, T>;
  bool get isFailure => this is Failure<E, T>;

  R fold<R>({
    required R Function(E e) failure,
    required R Function(T v) success,
  }) => switch (this) {
        Success(:final value) => success(value),
        Failure(:final error) => failure(error),
      };

  Result<E, R> map<R>(R Function(T v) transform) => switch (this) {
    Success(:final value) => Success<E, R>(transform(value)),
    Failure(:final error) => Failure<E, R>(error),
  };

  Result<F, T> mapError<F>(F Function(E e) transform) => switch (this) {
    Success(:final value) => Success<F, T>(value),
    Failure(:final error) => Failure<F, T>(transform(error)),
  };
}

class Success<E, T> extends Result<E, T> {
  const Success(this.value);

  final T value;

  @override
  String toString() => 'Success($value)';
  @override
  bool operator ==(Object other) =>
      other is Success<E, T> && other.value == value;
  @override
  int get hashCode => Object.hash('Success', value);
}

class Failure<E, T> extends Result<E, T> {
  const Failure(this.error);

  final E error;

  @override
  String toString() => 'Failure($error)';
  @override
  bool operator ==(Object other) =>
      other is Failure<E, T> && other.error == error;
  @override
  int get hashCode => Object.hash('Failure', error);
}

// Tests placeholder will be added in test directory later.
