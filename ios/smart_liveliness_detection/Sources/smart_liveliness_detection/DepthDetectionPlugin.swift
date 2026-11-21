import Flutter
#if !targetEnvironment(simulator)
import ARKit
#endif

@objc class DepthDetectionPlugin: NSObject, FlutterPlugin {

    #if !targetEnvironment(simulator)
    private var arSession: ARSession?
    #endif
    private var eventSink: FlutterEventSink?

    // MARK: - FlutterPlugin registration

    static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()

        let methodChannel = FlutterMethodChannel(
            name: "smart_liveliness_detection/depth",
            binaryMessenger: messenger)
        let eventChannel = FlutterEventChannel(
            name: "smart_liveliness_detection/depth/events",
            binaryMessenger: messenger)

        let instance = DepthDetectionPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    // MARK: - Method channel

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkAvailability":
            #if targetEnvironment(simulator)
            result(["available": false, "reason": "ARKit not available in simulator"])
            #else
            let available = ARFaceTrackingConfiguration.isSupported
            var response: [String: Any] = ["available": available]
            if !available {
                response["reason"] = "TrueDepth camera not available on this device"
            }
            result(response)
            #endif
        case "startSession":
            #if targetEnvironment(simulator)
            result(FlutterError(
                code: "UNAVAILABLE",
                message: "ARKit not available in simulator",
                details: nil))
            #else
            startARSession(result: result)
            #endif
        case "stopSession":
            #if !targetEnvironment(simulator)
            stopARSession()
            #endif
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - AR session control

    #if !targetEnvironment(simulator)
    private func startARSession(result: @escaping FlutterResult) {
        guard ARFaceTrackingConfiguration.isSupported else {
            result(FlutterError(
                code: "UNAVAILABLE",
                message: "TrueDepth camera not supported on this device",
                details: nil))
            return
        }
        let session = ARSession()
        session.delegate = self
        let config = ARFaceTrackingConfiguration()
        session.run(config, options: [.resetTracking, .removeExistingAnchors])
        arSession = session
        result(nil)
    }

    private func stopARSession() {
        arSession?.pause()
        arSession = nil
    }
    #endif
}

// MARK: - FlutterStreamHandler

extension DepthDetectionPlugin: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?,
                  eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}

// MARK: - ARSessionDelegate (device only)

#if !targetEnvironment(simulator)
extension DepthDetectionPlugin: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard
            let faceAnchor = anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor,
            let sink = eventSink
        else { return }

        let vertices = faceAnchor.geometry.vertices
        let count = vertices.count
        guard count > 0 else { return }

        var sum: Float = 0.0
        for v in vertices { sum += v.z }
        let mean: Float = sum / Float(count)

        var varianceSum: Float = 0.0
        for v in vertices {
            let diff = v.z - mean
            varianceSum += diff * diff
        }
        let variance: Float = varianceSum / Float(count)
        let stdDev: Float = sqrt(variance)

        let threshold: Float = 0.004
        let isFlat = stdDev < threshold
        let maxExpected: Float = 0.020
        let rawConfidence: Float = stdDev / maxExpected
        let confidence: Double = Double(rawConfidence < 1.0 ? rawConfidence : 1.0)

        sink([
            "depthVariance": Double(variance),
            "depthStdDev": Double(stdDev),
            "isFlat": isFlat,
            "confidence": confidence,
            "vertexCount": count,
        ])
    }
}
#endif
