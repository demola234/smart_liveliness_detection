import Flutter

/// Root plugin registrar for the smart_liveliness_detection package.
@objc public class SmartLivelinessDetectionPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        DepthDetectionPlugin.register(with: registrar)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
}
