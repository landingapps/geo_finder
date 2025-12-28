import Flutter
import UIKit
import CoreLocation
import CoreMotion

public class GeoFinderPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    private var channel: FlutterMethodChannel?
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()

    private var locationEventSink: FlutterEventSink?
    private var headingEventSink: FlutterEventSink?
    private var orientationEventSink: FlutterEventSink?

    private var pendingLocationResult: FlutterResult?
    private var pendingHeadingResult: FlutterResult?
    private var pendingOrientationResult: FlutterResult?
    private var pendingPermissionResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "geo_finder", binaryMessenger: registrar.messenger())
        let instance = GeoFinderPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)

        // EventChannels for streams
        let locationEventChannel = FlutterEventChannel(name: "geo_finder/location", binaryMessenger: registrar.messenger())
        locationEventChannel.setStreamHandler(LocationStreamHandler(plugin: instance))

        let headingEventChannel = FlutterEventChannel(name: "geo_finder/heading", binaryMessenger: registrar.messenger())
        headingEventChannel.setStreamHandler(HeadingStreamHandler(plugin: instance))

        let orientationEventChannel = FlutterEventChannel(name: "geo_finder/orientation", binaryMessenger: registrar.messenger())
        orientationEventChannel.setStreamHandler(OrientationStreamHandler(plugin: instance))
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Helper for authorization status (iOS 14+ compatibility)

    private func getAuthorizationStatus() -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getCurrentLocation":
            getCurrentLocation(result: result)
        case "getHeading":
            getHeading(result: result)
        case "getDeviceOrientation":
            getDeviceOrientation(result: result)
        case "requestLocationPermission":
            requestLocationPermission(result: result)
        case "checkLocationPermission":
            checkLocationPermission(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Location

    private func getCurrentLocation(result: @escaping FlutterResult) {
        let status = getAuthorizationStatus()

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            result(FlutterError(code: "PERMISSION_DENIED",
                              message: "Location permission not granted",
                              details: nil))
            return
        }

        pendingLocationResult = result
        locationManager.requestLocation()
    }

    // MARK: - Heading (Compass)

    private func getHeading(result: @escaping FlutterResult) {
        guard CLLocationManager.headingAvailable() else {
            result(FlutterError(code: "UNAVAILABLE",
                              message: "Heading not available on this device",
                              details: nil))
            return
        }

        pendingHeadingResult = result
        locationManager.startUpdatingHeading()
    }

    // MARK: - Device Orientation (Motion)

    private func getDeviceOrientation(result: @escaping FlutterResult) {
        guard motionManager.isDeviceMotionAvailable else {
            result(FlutterError(code: "UNAVAILABLE",
                              message: "Device motion not available",
                              details: nil))
            return
        }

        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] (motion, error) in
            self?.motionManager.stopDeviceMotionUpdates()

            if let error = error {
                result(FlutterError(code: "ERROR",
                                  message: error.localizedDescription,
                                  details: nil))
                return
            }

            guard let motion = motion else {
                result(FlutterError(code: "NULL_RESULT",
                                  message: "Failed to get device motion",
                                  details: nil))
                return
            }

            let attitude = motion.attitude
            result([
                "pitch": attitude.pitch * 180.0 / .pi,
                "roll": attitude.roll * 180.0 / .pi,
                "yaw": attitude.yaw * 180.0 / .pi,
                "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
            ])
        }
    }

    // MARK: - Permissions

    private func requestLocationPermission(result: @escaping FlutterResult) {
        let status = getAuthorizationStatus()

        switch status {
        case .notDetermined:
            pendingPermissionResult = result
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            result(true)
        case .denied, .restricted:
            result(false)
        @unknown default:
            result(false)
        }
    }

    private func checkLocationPermission(result: @escaping FlutterResult) {
        let status = getAuthorizationStatus()

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            result(true)
        default:
            result(false)
        }
    }

    // MARK: - CLLocationManagerDelegate

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "altitude": location.altitude,
            "accuracy": location.horizontalAccuracy,
            "timestamp": Int64(location.timestamp.timeIntervalSince1970 * 1000)
        ]

        if let pendingResult = pendingLocationResult {
            pendingResult(locationData)
            pendingLocationResult = nil
        }

        locationEventSink?(locationData)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let pendingResult = pendingLocationResult {
            pendingResult(FlutterError(code: "LOCATION_ERROR",
                                      message: error.localizedDescription,
                                      details: nil))
            pendingLocationResult = nil
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let headingData: [String: Any] = [
            "trueHeading": newHeading.trueHeading,
            "magneticHeading": newHeading.magneticHeading,
            "accuracy": newHeading.headingAccuracy,
            "timestamp": Int64(newHeading.timestamp.timeIntervalSince1970 * 1000)
        ]

        if let pendingResult = pendingHeadingResult {
            pendingResult(headingData)
            pendingHeadingResult = nil
            locationManager.stopUpdatingHeading()
        }

        headingEventSink?(headingData)
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // For iOS 13 and earlier
        handleAuthorizationChange(status: status)
    }

    @available(iOS 14.0, *)
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // For iOS 14 and later
        handleAuthorizationChange(status: manager.authorizationStatus)
    }

    private func handleAuthorizationChange(status: CLAuthorizationStatus) {
        if pendingPermissionResult != nil {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                pendingPermissionResult?(true)
            default:
                pendingPermissionResult?(false)
            }
            pendingPermissionResult = nil
        }
    }

    // MARK: - Stream Control

    func startLocationUpdates(eventSink: @escaping FlutterEventSink) {
        locationEventSink = eventSink
        locationManager.startUpdatingLocation()
    }

    func stopLocationUpdates() {
        locationEventSink = nil
        locationManager.stopUpdatingLocation()
    }

    func startHeadingUpdates(eventSink: @escaping FlutterEventSink) {
        headingEventSink = eventSink
        locationManager.startUpdatingHeading()
    }

    func stopHeadingUpdates() {
        headingEventSink = nil
        locationManager.stopUpdatingHeading()
    }

    func startOrientationUpdates(eventSink: @escaping FlutterEventSink) {
        orientationEventSink = eventSink

        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] (motion, error) in
            guard let motion = motion, error == nil else { return }

            let attitude = motion.attitude
            self?.orientationEventSink?([
                "pitch": attitude.pitch * 180.0 / .pi,
                "roll": attitude.roll * 180.0 / .pi,
                "yaw": attitude.yaw * 180.0 / .pi,
                "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
            ])
        }
    }

    func stopOrientationUpdates() {
        orientationEventSink = nil
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - Stream Handlers

class LocationStreamHandler: NSObject, FlutterStreamHandler {
    private weak var plugin: GeoFinderPlugin?

    init(plugin: GeoFinderPlugin) {
        self.plugin = plugin
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.startLocationUpdates(eventSink: events)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.stopLocationUpdates()
        return nil
    }
}

class HeadingStreamHandler: NSObject, FlutterStreamHandler {
    private weak var plugin: GeoFinderPlugin?

    init(plugin: GeoFinderPlugin) {
        self.plugin = plugin
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.startHeadingUpdates(eventSink: events)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.stopHeadingUpdates()
        return nil
    }
}

class OrientationStreamHandler: NSObject, FlutterStreamHandler {
    private weak var plugin: GeoFinderPlugin?

    init(plugin: GeoFinderPlugin) {
        self.plugin = plugin
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.startOrientationUpdates(eventSink: events)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.stopOrientationUpdates()
        return nil
    }
}
