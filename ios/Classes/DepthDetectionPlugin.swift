import ARKit
import Flutter


@objc class DepthDetectionPlugin: NSObject, FlutterPlugin, ARSessionDelegate {

    private var arSession: ARSession?
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
            let available = ARFaceTrackingConfiguration.isSupported
            var response: [String: Any] = ["available": available]
            if !available {
                response["reason"] = "TrueDepth camera not available on this device"
            }
            result(response)
        case "startSession":
            startARSession(result: result)
        case "stopSession":
            stopARSession()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - AR session control

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

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard
            let faceAnchor = anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor,
            let sink = eventSink
        else { return }

        // ARFaceGeometry.vertices is [simd_float3]; use .count for the vertex count.
        let vertices = faceAnchor.geometry.vertices
        let count = vertices.count
        guard count > 0 else { return }

        // Compute Z-axis standard deviation across the face mesh (metres).
        // Real face: stdDev ≈ 0.008–0.020 m (nose protrudes, eye sockets recede).
        // Flat photo: stdDev < 0.003 m.
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

        let threshold: Float = 0.004 // metres
        let isFlat = stdDev < threshold
        // Clamp confidence to 0.0–1.0 using explicit Float arithmetic.
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
