import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  private static let channelName = "io.ringlex.scanote/notifications"
  private static let openNotificationSettings = "openNotificationSettings"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Lets flutter_local_notifications show event reminders while the app is
    // in the foreground.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    registerNotificationSettingsChannel()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Answers the settings screen when it asks to be taken to the system
  /// notification settings, the only place the permission can be changed once
  /// the prompt has been answered.
  private func registerNotificationSettingsChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: AppDelegate.channelName,
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      guard call.method == AppDelegate.openNotificationSettings else {
        result(FlutterMethodNotImplemented)
        return
      }

      // iOS 16 opens the notifications page itself, older versions land on the
      // app's own settings, which holds it.
      var settingsUrl = URL(string: UIApplication.openSettingsURLString)

      if #available(iOS 16.0, *) {
        settingsUrl = URL(string: UIApplication.openNotificationSettingsURLString) ?? settingsUrl
      }

      guard let url = settingsUrl, UIApplication.shared.canOpenURL(url) else {
        result(false)
        return
      }

      UIApplication.shared.open(url, options: [:]) { isOpened in
        result(isOpened)
      }
    }
  }
}
