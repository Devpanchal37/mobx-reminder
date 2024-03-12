// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LocalDatabaseState on _LocalDatabaseState, Store {
  late final _$connectivitySubscriptionAtom = Atom(
      name: '_LocalDatabaseState.connectivitySubscription', context: context);

  @override
  StreamSubscription<dynamic>? get connectivitySubscription {
    _$connectivitySubscriptionAtom.reportRead();
    return super.connectivitySubscription;
  }

  @override
  set connectivitySubscription(StreamSubscription<dynamic>? value) {
    _$connectivitySubscriptionAtom
        .reportWrite(value, super.connectivitySubscription, () {
      super.connectivitySubscription = value;
    });
  }

  late final _$isConnectedAtom =
      Atom(name: '_LocalDatabaseState.isConnected', context: context);

  @override
  bool get isConnected {
    _$isConnectedAtom.reportRead();
    return super.isConnected;
  }

  @override
  set isConnected(bool value) {
    _$isConnectedAtom.reportWrite(value, super.isConnected, () {
      super.isConnected = value;
    });
  }

  late final _$_LocalDatabaseStateActionController =
      ActionController(name: '_LocalDatabaseState', context: context);

  @override
  void isConnectedTrueFunc(bool connected) {
    final _$actionInfo = _$_LocalDatabaseStateActionController.startAction(
        name: '_LocalDatabaseState.isConnectedTrueFunc');
    try {
      return super.isConnectedTrueFunc(connected);
    } finally {
      _$_LocalDatabaseStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void initConnectivity() {
    final _$actionInfo = _$_LocalDatabaseStateActionController.startAction(
        name: '_LocalDatabaseState.initConnectivity');
    try {
      return super.initConnectivity();
    } finally {
      _$_LocalDatabaseStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void disposeConnectivity() {
    final _$actionInfo = _$_LocalDatabaseStateActionController.startAction(
        name: '_LocalDatabaseState.disposeConnectivity');
    try {
      return super.disposeConnectivity();
    } finally {
      _$_LocalDatabaseStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
connectivitySubscription: ${connectivitySubscription},
isConnected: ${isConnected}
    ''';
  }
}
