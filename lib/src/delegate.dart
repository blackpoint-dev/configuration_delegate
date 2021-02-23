import 'dart:async';

import 'package:meta/meta.dart';

/// [T] type should override hashCode and equals so the stream can properly
/// emit only distinct events.
///
/// When you provide `initialValue` it is immediately emitted from the [watch].
abstract class ConfigurationDelegate<T> {
  ConfigurationDelegate({
    T initialValue,
  }) : _controller = StreamController<T>.broadcast() {
    if (initialValue != null) {
      _controller.add(initialValue);
    }
  }

  String get key;

  // TODO: Shall we use `BehaviorSubject` from rxdart package?
  final StreamController<T> _controller;

  FutureOr<T> get();

  /// Whenever you override [set] you must call super at the of your method.
  ///
  /// ```dart
  /// @override
  /// Future<void> set(String value)  {
  ///   // ... your code
  ///   super.set(value);
  /// }
  /// ```
  @mustCallSuper
  Future<void> set(T value) async {
    _controller.add(value);
  }

  @protected
  Stream<T> watch() => _controller.stream.distinct();
}
