import 'dart:async';
import 'dart:convert';

import 'package:configuration_delegate/configuration_delegate.dart';

Future<void> main() async {
  final store = <String, dynamic>{};
  final repository = ConfigurationRepository(store)
    ..name.watch().listen((event) {
      print('Update stream event: $event');
    });

  print('Initial name: ${await repository.name.get()}');
  await repository.name.set('John Doe');
  print('Name after change: ${await repository.name.get()}');

  final user = User(name: 'Peter', age: 21);
  repository.user.set(user);
  print('User: ${await repository.user.get()}');
}

/// [ConfigurationRepository] provides field for every configuration item while
/// delegating all work into its individual [ConfigurationDelegate] classes.
class ConfigurationRepository {
  ConfigurationRepository(
    Map<String, dynamic> _store,
  )   : name = _NameConfiguration(_store),
        user = _UserConfiguration(_store);

  final _NameConfiguration name;

  final _UserConfiguration user;
}

class _NameConfiguration extends ConfigurationDelegate<String> {
  _NameConfiguration(this._store);

  @override
  String get key => 'name';

  final Map<String, dynamic> _store;

  @override
  Future<String> get() {
    return _store[key] ?? 'DEFAULT VALUE';
  }

  @override
  Future<void> set(String value) {
    _store[key] = value;
    return super.set(value);
  }
}

class User {
  User({this.name, this.age});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      age: json['age'] as int,
    );
  }

  final String name;
  final int age;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'age': age,
    };
  }

  @override
  String toString() => 'User{name: $name, age: $age}';
}

class _UserConfiguration extends ConfigurationDelegate<User> {
  _UserConfiguration(this._store);

  @override
  String get key => 'user';

  final Map<String, dynamic> _store;

  @override
  Future<User> get() async {
    final value = _store[key];

    if (value != null) {
      return User.fromJson(json.decode(value));
    } else {
      return null;
    }
  }

  @override
  Future<void> set(User value) {
    _store[key] = json.encode(value.toJson());
    return super.set(value);
  }
}
