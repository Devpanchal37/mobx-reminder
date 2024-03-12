import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:mobx_reminder/hive_service/hive_reminder_model.dart';
import 'package:mobx_reminder/main.dart';
import 'package:mobx_reminder/state/reminder.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

//
// class FutureBoolAdapter extends TypeAdapter<Future<bool>> {
//   @override
//   final typeId = 100; // Unique identifier for the adapter
//
//   @override
//   Future<bool> read(BinaryReader reader) {
//     // Deserialize the data and return Future<bool>
//     return Future.value(reader.readBool());
//   }
//
//   @override
//   Future<void> write(BinaryWriter writer, Future<bool> obj) async {
//     // Serialize the data and write to the binary writer
//     writer.writeBool(await obj);
//   }
// }

//
Future<bool> deleteReminderHiveFunc({required String reminderId}) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  print("deleted reminderId for put in hive box is $reminderId");
  try {
    // if user delete reminder then it store in HIVE DB and hive db store unique key which I prefer a increment number
    // so share pref is use to store the last index so when user close and open app again and delete another reminder after that
    // It store in hive db with next index store in share pref
    int index = pref.getInt("deleteReminder") ?? 0;
    try {
      await box
          .put(
        index,
        reminderId,
      )
          .then(
        (value) async {
          //reminder which is CREATED OFFLINE and DELETED OFFLINE is also  REMOVE from HIVE
          //So it is not CREATED when USER is ONLINE
          print(
              "deleted reminder id is added in hive and .then() function run");
          if (reminderBox.isNotEmpty) {
            int reminderBoxLength = reminderBox.length;
            for (int i = 0; i < reminderBoxLength; i++) {
              print("box index is: $i");
              ReminderHive? result = reminderBox.get(i);
              print("value at index $i is $result");
              try {
                if (reminderId == result!.id) {
                  await reminderBox.delete(i);
                  print(
                      "reminder which is CREATED OFFLINE and DELETED OFFLINE is REMOVE from HIVE successfully");
                } else {
                  print("else printed");
                }
              } catch (e) {
                print("hive error: $e");
              }
              if (i == (reminderBoxLength - 1)) {
                SharedPreferences pref = await SharedPreferences.getInstance();
                await pref.remove("createReminder");
              }
            }
          }

          print("delete reminder put successfully");
        },
      );
    } catch (e) {
      print("HIVE BOX PUTTING error : $e");
    }
    print("function add successfully");
    var action = await box.get(index);
    print("box put at index is: $index");
    index = index + 1;
    await pref.setInt("deleteReminder", index);
    print("box length is: ${box.length}");
    print("function in box is $action");
    // await action;
    // await box.clear();
  } catch (error) {
    print("HIVE delete error : $error");
  }
  return true;
}

//if internet is OFF and delete the reminder and after close and open app again
// then it fetch from firebase catch so remove that delete from local reminder
Future<void> checkIfDeletedInLocal() async {
  final int length = box.length;
  print("check for delete locally run");
  for (int i = 0; i < length; i++) {
    print("box index is: $i");
    var result = await box.get(i);
    print("value at index $i is $result");
    print("result is $result");
    try {
      appState.reminders.removeWhere((element) => element.id == result);
      print("reminder locally deleted");
    } catch (e) {
      print("locally delete error: $e");
    }
  }
}

// STORE the CREATED reminder in HIVE DB,when USER is OFFLINE
Future<bool> createReminderHiveFunc({required ReminderHive reminder}) async {
  print("hive reminder is : $reminder}");
  SharedPreferences pref = await SharedPreferences.getInstance();
  try {
    int index = pref.getInt("createReminder") ?? 0;
    try {
      await reminderBox
          .put(
        index,
        reminder,
      )
          .then(
        (value) {
          print("Create reminder put successfully");
        },
      );
    } catch (e) {
      print("HIVE BOX PUTTING error : $e");
    }
    var action = await box.get(index);
    print("create reminder box put at index is: $index");
    index = index + 1;
    await pref.setInt("createReminder", index);
    print("box length is: ${box.length}");
    print("create reminder function in box is $action");
    await createHiveLocalReminderFunc();
    return true;
  } catch (e) {
    print("created reminder HIVE CREATE reminder ERROR : $e");
    return false;
  }
}

//When user is OFFLINE and DELETE a reminder
//call this FUNCTION when USER is ONLINE and need to DELETE the reminder from firebase
Future<void> deleteReminderHiveProcessFunc() async {
  // var box = await Hive.openBox("myBox");
  final int length = box.length;
  for (int i = 0; i < length; i++) {
    print("boxx indexx is: $i");
    var result = await box.get(i);
    print("value at index $i is $result");
    await appState.deleteReminderFromFirebase(result);
    try {
      if (box.containsKey(i)) {
        box.delete(i);
      } else {
        print("else printeddd");
      }
    } catch (e) {
      print("hivee error: $e");
    }
    if (i == (length - 1)) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove("deleteReminder");
    }
  }
}

// When user is OFFLINE and CREATE a REMINDER, it need to Store in REMINDERS LIST,so it reflect it to the user
Future<void> createHiveLocalReminderFunc() async {
  for (int i = 0; i < reminderBox.length; i++) {
    print("boxx indexx is: $i");
    ReminderHive? result = reminderBox.get(i);
    print("value at index $i is $result");
    await appState.createLocalReminder(
        result!.id, result.text, result.creationDate);
    // Reminder hiveReminder = Reminder(
    //     id: result!.id,
    //     creationDate: result.creationDate,
    //     text: result.text,
    //     isDone: result.isDone);
    // appState.reminders.add(hiveReminder);
    // print(hiveReminder);
  }
  reminderBox.isEmpty ? print("boxx is emptyy") : print("box is not empty");
}

// user is OFFLINE and CREATE a reminder and after user is ONLINE
// then this function add the reminder is FIREBASE
Future<void> createHiveFirebaseReminderFunc() async {
  int reminderBoxLength = reminderBox.length;
  for (int i = 0; i < reminderBoxLength; i++) {
    print("firbase reminder create for loop");
    print("boxx indexx is: $i");
    ReminderHive? result = reminderBox.get(i);
    print("value at index $i is $result");
    await appState.createFirebaseReminder(result!.text, result.creationDate);
    await changeReminderId(hiveReminderCreationDate: result.creationDate);
    print("change reminder success");
    try {
      if (reminderBox.containsKey(i)) {
        reminderBox.delete(i);
      } else {
        print("else printeddd");
      }
    } catch (e) {
      print("hivee error: $e");
    }
    if (i == (reminderBoxLength - 1)) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.remove("createReminder");
    }
  }
  reminderBox.isEmpty ? print("boxx is emptyy") : print("box is not empty");
}

Future<bool> changeReminderId(
    {required DateTime hiveReminderCreationDate}) async {
  print("change reminder function run");
  try {
    Reminder changeIdReminder = appState.reminders.firstWhere(
      (element) => element.creationDate == hiveReminderCreationDate,
    );
    print("change reminder is $changeIdReminder");
    final userId = appState.currentUser?.uid;
    if (userId == null) {
      return false;
    }
    final collection = FirebaseFirestore.instance.collection(userId);
    final updatedReminderDocs = await collection
        .where("creationDate", isEqualTo: hiveReminderCreationDate)
        .limit(1)
        .get();
    if (updatedReminderDocs.docs.isNotEmpty) {
      final DocumentSnapshot updatedReminderId = updatedReminderDocs.docs.first;
      print("doc file is ${updatedReminderId.id}");
      changeIdReminder.id = updatedReminderId.id;
      appState.reminders.forEach((element) {
        print("element is : ${element.id}");
      });
    }

    return true;
  } catch (e) {
    print("change reminder ID error is $e");
    return false;
  }
  // reminderBox.isEmpty ? print("boxx is emptyy") : print("box is not empty");
}
