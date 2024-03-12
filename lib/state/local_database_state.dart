import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobx/mobx.dart';
import 'package:mobx_reminder/hive_service/hive_service.dart';
import 'package:mobx_reminder/main.dart';
import 'package:mobx_reminder/offline_queue.dart';
part 'local_database_state.g.dart';

class LocalDatabaseState = _LocalDatabaseState with _$LocalDatabaseState;

abstract class _LocalDatabaseState with Store {
  final offlineQueue = OfflineQueue();

  final Connectivity _connectivity = Connectivity();
  @observable
  StreamSubscription? connectivitySubscription;

  @observable
  bool isConnected = false;
  @action
  void isConnectedTrueFunc(bool connected) {
    isConnected = connected;
    print("is user online: $isConnected");
  }

  @action
  void initConnectivity() {
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) async {
      print(result);
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        isConnectedTrueFunc(true);
        if (box.isNotEmpty) {
          await deleteReminderHiveProcessFunc();
        } else {
          print("box is empty on turning internet");
        }
        if (reminderBox.isNotEmpty) {
          createHiveFirebaseReminderFunc();
        } else {
          print("reminder box is empty on turning internet");
        }
        // await offlineQueue.processQueue().then(
        //   (value) {
        //     print("work successfullyyyy");
        //   },
        // );
      } else {
        isConnectedTrueFunc(false);
      }
    });
  }

  @action
  void disposeConnectivity() {
    connectivitySubscription?.cancel();
  }
}
