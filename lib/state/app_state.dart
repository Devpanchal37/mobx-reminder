import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:mobx_reminder/auth/auth_error.dart';
import 'package:mobx_reminder/hive_service/hive_reminder_model.dart';
import 'package:mobx_reminder/hive_service/hive_service.dart';
import 'package:mobx_reminder/main.dart';
import 'package:mobx_reminder/offline_queue.dart';
import 'package:mobx_reminder/state/reminder.dart';
import 'package:nb_utils/nb_utils.dart';

part 'app_state.g.dart';

class AppState = _AppState with _$AppState;

abstract class _AppState with Store {
  final offlineQueue = OfflineQueue();

  @observable
  AppScreen currentScreen = AppScreen.login;

  @observable
  bool isLoading = false;
  @observable
  User? currentUser;
  @observable
  AuthError? authError;

  @observable
  ObservableList<Reminder> reminders = ObservableList<Reminder>();
  @computed
  ObservableList<Reminder> get sortedReminders =>
      ObservableList.of(reminders.sorted());
  @action
  void goTo(AppScreen screen) {
    currentScreen = screen;
  }

  @action
  Future<bool> deleteReminderFromFirebase(String reminderid) async {
    print("DELETED TEXT IS ${reminderid}");
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) {
      return false;
    }
    final userId = user.uid;
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();
    print("collection iss ${collection.size}");
    try {
      // delete from firebase
      print("deleted reminder id:   ${reminderid}");

      final firebaseReminder = collection.docs.firstWhere((element) {
        print("element id ${element.id} and reminder id: ${reminderid}");
        return element.id == reminderid;
      });
      print("reference is ${firebaseReminder.reference}");
      await firebaseReminder.reference.delete().then((value) {
        print("deleted successfully");
      });
      return true;
    } catch (_) {
      return false;
    } finally {}
  }

  @action
  Future<bool> delete(String reminderid) async {
    isLoading = true;
    if (localDatabaseState.isConnected) {
      await deleteReminderFromFirebase(reminderid);

      print("localDatabaseState isConnected");
    } else {
      print("id is ${reminderid}");
      await deleteReminderHiveFunc(reminderId: reminderid);
      print("localDatabaseState isNOTConnected");
    }
    // final auth = FirebaseAuth.instance;
    // final user = auth.currentUser;
    // if (user == null) {
    //   return false;
    // }
    // final userId = user.uid;
    // final collection =
    //     await FirebaseFirestore.instance.collection  (userId).get();
    //
    // // delete from firebase
    // print("reminderr idddddddd:   ${reminder.id}");
    //
    // final firebaseReminder =
    //     collection.docs.firstWhere((element) => element.id == reminder.id);
    // print("referenceeeeeeeeeeeeeeee is ${firebaseReminder.reference}");
    // await firebaseReminder.reference.delete();
    try {
      reminders.removeWhere((element) => element.id == reminderid);
      return true;
      // delete from locally
    } catch (_) {
      print("delete reminder error");
      isLoading = false;
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> deleteAccount() async {
    isLoading = true;
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) {
      return false;
    }
    final userId = user.uid;
    try {
      final store = FirebaseFirestore.instance;
      final batch = store.batch();
      final collection = await store.collection(userId).get();
      for (final document in collection.docs) {
        batch.delete(document.reference);
      }
      // delete all document for this user
      await batch.commit();
      // delete user accunt
      await user.delete();
      await auth.signOut();
      currentScreen = AppScreen.login;
      return true;
    } on FirebaseAuthException catch (e) {
      authError = AuthError.from(e);
      print("delete account error is ${e}");
      return false;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> logOut() async {
    isLoading = true;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    isLoading = false;
    currentScreen = AppScreen.login;
    reminders.clear();
  }

  @action
  Future<bool> createFirebaseReminder(
      String text, DateTime creationDate) async {
    final userId = currentUser?.uid;
    print("firebase userId when CREATE REMINDER: ${userId}");
    print("created text is : ${text} and date is $creationDate");
    if (userId == null) {
      isLoading = false;
      return false;
    }
    // final creationDate = DateTime.now();
    try {
      final firebaseReminder =
          await FirebaseFirestore.instance.collection(userId).add({
        _DocumentKeys.text: text,
        _DocumentKeys.creationDate: creationDate,
        _DocumentKeys.isDone: false
      });
      // print("BEFORRRRREEEE changing ID reminder issssss: ${reminders.last.id}");

      // Reminder reminder = reminders.firstWhere(
      //   (element) => element.id == "${text}____ggggg",
      //   orElse: () => reminders[reminders.length - 1],
      // );
      // print("reminderrrrrr at indexx is ${reminder}");
      // reminder.id = firebaseReminder.id;
      // print("AFTERRRRRRR changing ID reminder issssss: ${reminders.last.id}");
      // print("created reminder is : ${reminder.id}");
      await createLocalReminder(firebaseReminder.id, text, creationDate);
      print("local reminder created ");
      return true;
    } catch (e) {
      print("firebase Reminder create error : ${e}");
      return false;
    } finally {
      print("finally is run");
      isLoading = false;
    }

    // print("reminderrrrrrrrrrrrrrrrr id : ${firebaseReminder.id}");
  }

  Future<bool> createLocalReminder(
      String reminderId, String text, DateTime creationDate) async {
    //When user is OFFLINE and CREATE a reminder and close the app and OPEN again
    // then CREATED reminder show from HIVE DB and it's a LOCAL reminder
    // and when user Turn ON INTERNET then FIREBASE reminder is CREATED
    // SO the CREATED reminder does not going to add in LOCAL reminder again
    for (var element in reminders) {
      if (element.creationDate == creationDate) {
        return false;
      }
    }
    try {
      final reminder = Reminder(
          id: reminderId,
          // id: "${text}____ggggg",
          creationDate: creationDate,
          text: text,
          isDone: false);
      print("reminder is ${reminder.isDone}");
      reminders.add(reminder);
      print("sorted reminder is $sortedReminders");
    } catch (e) {
      print("local reminder CREATE error: $e");
      return false;
    } finally {}
    return true;
  }

  @action
  Future<bool> createReminder(String text) async {
    isLoading = true;
    final creationDate = DateTime.now();

    if (localDatabaseState.isConnected) {
      print(
          "user is ONLINE when creating a REMINDER and text is : $text, and creation Date is : $creationDate ");
      //it will create FIREBASE REMINDER AS WELL AS LOCAL REMINDER TOO
      await createFirebaseReminder(text, creationDate);
    } else {
      // final reminder1 = Reminder(
      //     id: " ", creationDate: creationDate, text: text, isDone: false);
      // print("reminder to be created is ${reminder1}");

      final reminder = ReminderHive(
          id: "${text}abcd",
          creationDate: creationDate,
          text: text,
          isDone: false);
      print("reminder to be created is $reminder");
      await createReminderHiveFunc(reminder: reminder);
    }
    // final userId = currentUser?.uid;
    // print("helllllllooooooooooooo: ${userId}");
    // if (userId == null) {
    //   isLoading = false;
    //   return false;
    // }
    // final creationDate = DateTime.now();

    // final firebaseReminder =
    //     await FirebaseFirestore.instance.collection(userId).add({
    //   _DocumentKeys.text: text,
    //   _DocumentKeys.creationDate: creationDate,
    //   _DocumentKeys.isDone: false
    // }).catchError((error) {
    //   print("create reminder error");
    //   return error;
    // });
    // print("reminderrrrrrrrrrrrrrrrr id : ${firebaseReminder.id}");

    // final reminder = Reminder(
    //     id: firebaseReminder.id,
    //     // id: "${text}____ggggg",
    //     creationDate: creationDate,
    //     text: text,
    //     isDone: false);
    // print("reminderrrr is ${reminder.id}");
    // print("reminder   issssssssssssssssss ${reminder.isDone}");
    // reminders.add(reminder);
    // print("sorteeddddddddd reminderrrrrrrrr is ${sortedReminders}");
    // print("before: ${isLoading}");
    isLoading = false;
    print("after: ${isLoading}");
    return true;
  }

  @action
  Future<bool> modify(Reminder reminder, {required bool isDone}) async {
    final userId = currentUser?.uid;
    if (userId == null) {
      return false;
    }
    // update the remote reminder
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();
    final firebaseReminder = collection.docs
        .where((element) => element.id == reminder.id)
        .first
        .reference;
    await firebaseReminder.update({_DocumentKeys.isDone: isDone});
    // update the local reminder
    reminders.firstWhere((element) => element.id == reminder.id).isDone =
        isDone;
    return true;
  }

  @action
  Future<void> initialize() async {
    print("initialize runn");
    isLoading = true;

    // initConnectivity();
    localDatabaseState.initConnectivity();
    currentUser = FirebaseAuth.instance.currentUser;
    print("initialize time user: ${currentUser}");
    if (currentUser != null) {
      // TODO: LOAD THE REMINDER SCREEN FROM FIREBASE
      await _loadReminder();
      currentScreen = AppScreen.reminders;
    } else {
      print("login screen");
      currentScreen = AppScreen.login;
    }
    isLoading = false;
  }

  @action
  Future<bool> _loadReminder() async {
    final userId = currentUser?.uid;
    if (userId == null) {
      return false;
    }
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();
    final reminderss = collection.docs.map((docs) => Reminder(
        id: docs.id,
        creationDate: (docs[_DocumentKeys.creationDate] as Timestamp).toDate(),
        text: docs[_DocumentKeys.text],
        isDone: docs[_DocumentKeys.isDone] as bool));
    reminders = ObservableList.of(reminderss);
    if (reminderBox.isNotEmpty) {
      print("reminder box is not empty");
      await createHiveLocalReminderFunc();
      print("after hive local : $reminders");
    } else {
      print("reminder box is empty");
    }
    await checkIfDeletedInLocal();
    print("reminder length whatever : ${this.reminders.length}");
    print("observable list : ${ObservableList.of(reminderss)}");
    for (var element in reminders) {
      print("reminder length in for loop ${reminderss.length}");
      print("local reminder id is : ${element.id}");
    }
    return true;
  }

  @action
  Future<bool> _registerOrLogin(
      {required LoginOrRegistration fn,
      required String email,
      required String password}) async {
    authError = null;
    isLoading = true;
    try {
      print("function run");
      await fn(email: email, password: password);
      currentUser = FirebaseAuth.instance.currentUser;
      print("current user is : ${currentUser}");
      return true;
    } on FirebaseAuthException catch (e) {
      print("register or login error is :${e}");
      currentUser = null;
      authError = AuthError.from(e);
      return false;
    } finally {
      print("finally User is ${currentUser}");
      isLoading = false;
      if (currentUser != null) {
        await _loadReminder();
        currentScreen = AppScreen.reminders;
      }
    }
  }

  @action
  Future<bool> register(
      {required String email, required String password}) async {
    bool xyz = await _registerOrLogin(
        fn: FirebaseAuth.instance.createUserWithEmailAndPassword,
        email: email,
        password: password);
    return xyz;
  }

  @action
  Future<bool> login({required String email, required String password}) =>
      _registerOrLogin(
          fn: FirebaseAuth.instance.signInWithEmailAndPassword,
          email: email,
          password: password);
}

abstract class _DocumentKeys {
  static const text = 'text';
  static const creationDate = 'creationDate';
  static const isDone = 'isDone';
}

//typedef: This keyword is used to declare a type alias, which is a way to give a name to a function type.
// LoginOrRegistration: This is the name of the type alias. You can use this name to refer to the specific function type.
typedef LoginOrRegistration = Future<UserCredential> Function(
    {required String email, required String password});

//int toInteger() => this ? 1 : 0;: This is the method added by the extension.
// The toInteger() method returns an integer (int) based on the boolean value.
// If the boolean value is true, it returns 1; otherwise, it returns 0. This is achieved using the ternary operator (? :),
// which is a concise way of expressing a conditional expression.
//. This extension adds a method called toInteger() to instances of the bool type

extension ToInt on bool {
  int toInteger() => this ? 1 : 0;
}

// extension Sorted on List<Reminder> {
//   List<Reminder> sorted() => [...this]..sort((lhs, rhs) {
//       print("object");
//       final isDone = lhs.isDone.toInteger().compareTo(rhs.isDone.toInteger());
//       if (isDone != 0) {
//         return isDone;
//       }
//       return lhs.creationDate.compareTo(rhs.creationDate);
//     });
// }
extension Sorted on List<Reminder> {
  List<Reminder> sorted() => [...this]..sort((lhs, rhs) {
      final isDone = lhs.isDone.toInteger().compareTo(rhs.isDone.toInteger());
      if (isDone != 0) {
        return isDone;
      }

      // Compare creation dates if isDone properties are equal
      final creationDateComparison =
          lhs.creationDate.compareTo(rhs.creationDate);
      if (creationDateComparison != 0) {
        return creationDateComparison;
      }

      // If creation dates are equal as well, use a tiebreaker based on another property
      // In this example, let's use a unique identifier (e.g., hash code)
      return lhs.hashCode.compareTo(rhs.hashCode);
    });
}

enum AppScreen { login, register, reminders }
