import 'dart:async';

import 'package:meta/meta.dart';

/// [ConfigurationDelegate] provides unified interface for your config items.
/// Extend this class for each configurable property in your app and override
/// needed methods.
///
/// Whenever you extend this class you must override [get] method and [key].
/// Must of the time you probably want to also override the [set] method.
///
/// [T] is the type of a configurable property. It can be String or JSON object.
/// You must implement serialization and deserialization methods for each type.
/// [T] type should also override hashCode and equals so the stream can properly
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

  /// [key] is used for uniquely identifying this property in a storage.
  String get key;

  // TODO: Shall we use `BehaviorSubject` from rxdart package?
  final StreamController<T> _controller;

  /// Get current property value.
  Future<T> get();

  /// Set new value for this configurable property.
  ///
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

  /// Use [watch] to subscribe for updates. Whenever you call [set] to change
  /// the value, [watch] will emit an event.
  Stream<T> watch() => _controller.stream.distinct();
}
