// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/helper/generalWidgets/permissionHandlerBottomSheet.dart';
import 'package:project/helper/utils/generalImports.dart';

class LocalAwesomeNotification {
  AwesomeNotifications? notification = AwesomeNotifications();
  static FirebaseMessaging? messagingInstance = FirebaseMessaging.instance;

  final String normalNotificationChannel = "normalNotification";
  final String soundNotificationChannel = "soundNotification";

  static LocalAwesomeNotification? localNotification =
      LocalAwesomeNotification();

  static late StreamSubscription<RemoteMessage>? foregroundStream;
  static late StreamSubscription<RemoteMessage>? onMessageOpen;

  init(BuildContext context) async {
    if (notification != null &&
        messagingInstance != null &&
        localNotification != null) {
      disposeListeners().then((value) async {
        await requestPermission(context: context);
        notification = AwesomeNotifications();
        messagingInstance = FirebaseMessaging.instance;
        localNotification = LocalAwesomeNotification();

        await registerListeners(context);

        await listenTap(context);

        await notification?.initialize(
          'resource://mipmap/logo',
          [
            NotificationChannel(
              channelKey: soundNotificationChannel,
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel',
              playSound: true,
              enableVibration: true,
              importance: NotificationImportance.High,
              ledColor: ColorsRes.appColor,
              soundSource: Platform.isIOS
                  ? "order_sound.aiff"
                  : "resource://raw/order_sound",
            ),
            NotificationChannel(
              channelKey: normalNotificationChannel,
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel',
              playSound: true,
              enableVibration: true,
              importance: NotificationImportance.High,
              ledColor: ColorsRes.appColor,
            )
          ],
          debug: kDebugMode,
        );
      });
    } else {
      await requestPermission(context: context);
      notification = AwesomeNotifications();
      messagingInstance = FirebaseMessaging.instance;
      localNotification = LocalAwesomeNotification();
      await registerListeners(context);

      await listenTap(context);

      await notification?.initialize(
        'resource://mipmap/logo',
        [
          NotificationChannel(
            channelKey: soundNotificationChannel,
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel',
            playSound: true,
            enableVibration: true,
            importance: NotificationImportance.High,
            ledColor: ColorsRes.appColor,
            soundSource: Platform.isIOS
                ? "order_sound.aiff"
                : "resource://raw/order_sound",
          ),
          NotificationChannel(
            channelKey: normalNotificationChannel,
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel',
            playSound: true,
            enableVibration: true,
            importance: NotificationImportance.High,
            ledColor: ColorsRes.appColor,
          )
        ],
        debug: kDebugMode,
      );
    }
  }

  @pragma('vm:entry-point')
  listenTap(BuildContext context) {
    try {
      notification?.setListeners(
          onDismissActionReceivedMethod: (receivedAction) async {},
          onNotificationDisplayedMethod: (receivedNotification) async {},
          onNotificationCreatedMethod: (receivedNotification) async {},
          onActionReceivedMethod: (ReceivedAction data) async {});
    } catch (e) {
      if (kDebugMode) {
        print("ERROR IS ${e.toString()}");
      }
    }
  }

  // Normal notification
  @pragma('vm:entry-point')
  createImageNotification(
      {required RemoteMessage data, required bool isLocked}) async {
    try {
      await notification?.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          color: ColorsRes.appColor,
          title: data.data["title"],
          locked: isLocked,
          payload: Map.from(data.data),
          autoDismissible: true,
          showWhen: true,
          notificationLayout: NotificationLayout.BigPicture,
          body: data.data["message"],
          wakeUpScreen: true,
          largeIcon: data.data["image"],
          bigPicture: data.data["image"],
          channelKey: normalNotificationChannel,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("ERROR IS ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  createNotification(
      {required RemoteMessage data, required bool isLocked}) async {
    try {
      await notification?.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          color: ColorsRes.appColor,
          title: data.data["title"],
          locked: isLocked,
          payload: Map.from(data.data),
          autoDismissible: true,
          showWhen: true,
          notificationLayout: NotificationLayout.Default,
          body: data.data["message"],
          wakeUpScreen: true,
          channelKey: normalNotificationChannel,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("ERROR IS ${e.toString()}");
      }
    }
  }

  // Sound notification, if new order received sound notification will be played
  @pragma('vm:entry-point')
  createImageNotificationWithSound(
      {required RemoteMessage data, required bool isLocked}) async {
    try {
      await notification?.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          color: ColorsRes.appColor,
          title: data.data["title"],
          locked: isLocked,
          payload: Map.from(data.data),
          autoDismissible: true,
          showWhen: true,
          notificationLayout: NotificationLayout.BigPicture,
          body: data.data["message"],
          wakeUpScreen: true,
          largeIcon: data.data["image"],
          bigPicture: data.data["image"],
          channelKey: soundNotificationChannel,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("ERROR IS ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  createNotificationWithSound(
      {required RemoteMessage data, required bool isLocked}) async {
    try {
      await notification?.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          color: ColorsRes.appColor,
          title: data.data["title"],
          locked: isLocked,
          payload: Map.from(data.data),
          autoDismissible: true,
          showWhen: true,
          notificationLayout: NotificationLayout.Default,
          body: data.data["message"],
          wakeUpScreen: true,
          channelKey: soundNotificationChannel,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("ERROR IS ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  requestPermission({required BuildContext context}) async {
    try {
      PermissionStatus notificationPermissionStatus =
          await Permission.notification.status;

      if (notificationPermissionStatus.isPermanentlyDenied) {
        if (!Constant.session.getBoolData(
            SessionManager.keyPermissionNotificationHidePromptPermanently)) {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Wrap(
                children: [
                  PermissionHandlerBottomSheet(
                    titleJsonKey: "notification_permission_title",
                    messageJsonKey: "notification_permission_message",
                    sessionKeyForAskNeverShowAgain: SessionManager
                        .keyPermissionNotificationHidePromptPermanently,
                  ),
                ],
              );
            },
          );
        }
      } else if (notificationPermissionStatus.isDenied) {
        await messagingInstance?.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        Permission.notification.request();
      }
    } catch (e) {
      if (kDebugMode) {
        print("ERROR IS ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessageHandler(RemoteMessage data) async {
    try {
      if (Platform.isAndroid) {
        if (data.data["sound"] == "default" || data.data["sound"] == null) {
          if (data.data["image"] == "" || data.data["image"] == null) {
            localNotification?.createNotification(isLocked: false, data: data);
          } else {
            localNotification?.createImageNotification(
                isLocked: false, data: data);
          }
        } else if (data.data["sound"] != "default") {
          if (data.data["image"] == "" || data.data["image"] == null) {
            localNotification?.createNotificationWithSound(
                isLocked: false, data: data);
          } else {
            localNotification?.createImageNotificationWithSound(
                isLocked: false, data: data);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("ISSUE ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  static foregroundNotificationHandler() async {
    try {
      onMessageOpen = FirebaseMessaging.onMessage.listen((RemoteMessage data) {
        if (Platform.isAndroid) {
          if (data.data["sound"] == "default" || data.data["sound"] == null) {
            if (data.data["image"] == "" || data.data["image"] == null) {
              localNotification?.createNotification(
                  isLocked: false, data: data);
            } else {
              localNotification?.createImageNotification(
                  isLocked: false, data: data);
            }
          } else if (data.data["sound"] != "default") {
            if (data.data["image"] == "" || data.data["image"] == null) {
              localNotification?.createNotificationWithSound(
                  isLocked: false, data: data);
            } else {
              localNotification?.createImageNotificationWithSound(
                  isLocked: false, data: data);
            }
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("ISSUE ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  static terminatedStateNotificationHandler() {
    messagingInstance?.getInitialMessage().then(
      (RemoteMessage? data) {
        if (data == null) {
          return;
        }

        if (Platform.isAndroid) {
          if (data.data["sound"] == "default" || data.data["sound"] == null) {
            if (data.data["image"] == "" || data.data["image"] == null) {
              localNotification?.createNotification(
                  isLocked: false, data: data);
            } else {
              localNotification?.createImageNotification(
                  isLocked: false, data: data);
            }
          } else if (data.data["sound"] != "default") {
            if (data.data["image"] == "" || data.data["image"] == null) {
              localNotification?.createNotificationWithSound(
                  isLocked: false, data: data);
            } else {
              localNotification?.createImageNotificationWithSound(
                  isLocked: false, data: data);
            }
          }
        }
      },
    );
  }

  @pragma('vm:entry-point')
  static registerListeners(context) async {
    try {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);
      messagingInstance?.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      await foregroundNotificationHandler();
      await terminatedStateNotificationHandler();
    } catch (e) {
      if (kDebugMode) {
        print("ERROR IS ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  Future disposeListeners() async {
    try {
      onMessageOpen?.cancel();
      foregroundStream?.cancel();
    } catch (e) {
      if (kDebugMode) {
        print("ERROR IS ${e.toString()}");
      }
    }
  }
}
