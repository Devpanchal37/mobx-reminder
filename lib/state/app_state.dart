import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';
import 'package:mobx_reminder/auth/auth_error.dart';
import 'package:mobx_reminder/state/reminder.dart';

part 'app_state.g.dart';

class AppState = _AppState with _$AppState;

abstract class _AppState with Store {
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
  Future<bool> delete(Reminder reminder) async {
    isLoading = true;
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) {
      return false;
    }
    final userId = user.uid;
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();
    try {
      // delete from firebase
      print("reminderr idddddddd:   ${reminder.id}");
      final firebaseReminder =
          collection.docs.firstWhere((element) => element.id == reminder.id);
      print("referenceeeeeeeeeeeeeeee is ${firebaseReminder.reference}");
      await firebaseReminder.reference.delete();
      reminders.removeWhere((element) => element.id == reminder.id);
      return true;
      // delete from locally
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }

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
  Future<bool> createReminder(String text) async {
    isLoading = true;
    final userId = currentUser?.uid;
    print("helllllllooooooooooooo: ${userId}");
    if (userId == null) {
      isLoading = false;
      return false;
    }
    final creationDate = DateTime.now();

    final firebaseReminder =
        await FirebaseFirestore.instance.collection(userId).add({
      _DocumentKeys.text: text,
      _DocumentKeys.creationDate: creationDate,
      _DocumentKeys.isDone: false
    }).catchError((error) {
      print("create reminder error");
      return error;
    });
    print("reminderrrrrrrrrrrrrrrrr id : ${firebaseReminder.id}");

    final reminder = Reminder(
        id: firebaseReminder.id,
        creationDate: creationDate,
        text: text,
        isDone: false);
    print("reminder   issssssssssssssssss ${reminder.isDone}");
    reminders.add(reminder);
    print("sorteeddddddddd reminderrrrrrrrr is ${sortedReminders}");
    isLoading = false;
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
    isLoading = true;
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // TODO: LOAD THE REMINDER SCREEN FROM FIREBASE
      await _loadReminder();
      currentScreen = AppScreen.reminders;
    } else {
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
    final reminders = collection.docs.map((docs) => Reminder(
        id: docs.id,
        creationDate: (docs[_DocumentKeys.creationDate] as Timestamp).toDate(),
        text: docs[_DocumentKeys.text],
        isDone: docs[_DocumentKeys.isDone] as bool));
    this.reminders = ObservableList.of(reminders);
    print("observable listtttt : ${ObservableList.of(reminders)}");
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
      print("hellllloooooooooooooo:${e}");
      currentUser = null;
      authError = AuthError.from(e);
      return false;
    } finally {
      print("finalyyyyyyyyyyyy User isssssssssssssss${currentUser}");
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

extension Sorted on List<Reminder> {
  List<Reminder> sorted() => [...this]..sort((lhs, rhs) {
      print("object");
      final isDone = lhs.isDone.toInteger().compareTo(rhs.isDone.toInteger());
      if (isDone != 0) {
        return isDone;
      }
      return lhs.creationDate.compareTo(rhs.creationDate);
    });
}

enum AppScreen { login, register, reminders }
