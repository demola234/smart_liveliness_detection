import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Allow flutter_tts (AVSpeechSynthesizer) to play even when the
    // ring/silent switch is off.
    try? AVAudioSession.sharedInstance().setCategory(
      .playback,
      mode: .default,
      options: .mixWithOthers
    )
    try? AVAudioSession.sharedInstance().setActive(true)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
