package jp.landingapps.geo_finder

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.Location
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class GeoFinderPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {

    private lateinit var channel: MethodChannel
    private lateinit var locationEventChannel: EventChannel
    private lateinit var headingEventChannel: EventChannel
    private lateinit var orientationEventChannel: EventChannel

    private var context: Context? = null
    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var sensorManager: SensorManager? = null

    private var pendingPermissionResult: Result? = null
    private var pendingLocationResult: Result? = null

    private var locationEventSink: EventChannel.EventSink? = null
    private var headingEventSink: EventChannel.EventSink? = null
    private var orientationEventSink: EventChannel.EventSink? = null

    private var locationCallback: LocationCallback? = null
    private var headingSensorListener: SensorEventListener? = null
    private var orientationSensorListener: SensorEventListener? = null

    private val accelerometerReading = FloatArray(3)
    private val magnetometerReading = FloatArray(3)
    private val rotationMatrix = FloatArray(9)
    private val orientationAngles = FloatArray(3)

    companion object {
        private const val PERMISSION_REQUEST_CODE = 1001
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(context!!)
        sensorManager = context!!.getSystemService(Context.SENSOR_SERVICE) as SensorManager

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "geo_finder")
        channel.setMethodCallHandler(this)

        locationEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "geo_finder/location")
        locationEventChannel.setStreamHandler(LocationStreamHandler())

        headingEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "geo_finder/heading")
        headingEventChannel.setStreamHandler(HeadingStreamHandler())

        orientationEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "geo_finder/orientation")
        orientationEventChannel.setStreamHandler(OrientationStreamHandler())
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getCurrentLocation" -> getCurrentLocation(result)
            "getHeading" -> getHeading(result)
            "getDeviceOrientation" -> getDeviceOrientation(result)
            "requestLocationPermission" -> requestLocationPermission(result)
            "checkLocationPermission" -> checkLocationPermission(result)
            else -> result.notImplemented()
        }
    }

    // Location
    private fun getCurrentLocation(result: Result) {
        if (!hasLocationPermission()) {
            result.error("PERMISSION_DENIED", "Location permission not granted", null)
            return
        }

        pendingLocationResult = result

        try {
            fusedLocationClient.lastLocation.addOnSuccessListener { location: Location? ->
                if (location != null) {
                    val locationData = mapOf(
                        "latitude" to location.latitude,
                        "longitude" to location.longitude,
                        "altitude" to location.altitude,
                        "accuracy" to location.accuracy.toDouble(),
                        "timestamp" to location.time
                    )
                    pendingLocationResult?.success(locationData)
                    pendingLocationResult = null
                } else {
                    requestSingleLocationUpdate()
                }
            }.addOnFailureListener { e ->
                pendingLocationResult?.error("LOCATION_ERROR", e.message, null)
                pendingLocationResult = null
            }
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", "Location permission not granted", null)
        }
    }

    private fun requestSingleLocationUpdate() {
        val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 1000)
            .setWaitForAccurateLocation(false)
            .setMinUpdateIntervalMillis(500)
            .setMaxUpdates(1)
            .build()

        val callback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                val location = locationResult.lastLocation
                if (location != null) {
                    val locationData = mapOf(
                        "latitude" to location.latitude,
                        "longitude" to location.longitude,
                        "altitude" to location.altitude,
                        "accuracy" to location.accuracy.toDouble(),
                        "timestamp" to location.time
                    )
                    pendingLocationResult?.success(locationData)
                } else {
                    pendingLocationResult?.error("NULL_RESULT", "Failed to get location", null)
                }
                pendingLocationResult = null
                try {
                    fusedLocationClient.removeLocationUpdates(this)
                } catch (_: Exception) {}
            }
        }

        try {
            fusedLocationClient.requestLocationUpdates(
                locationRequest,
                callback,
                Looper.getMainLooper()
            )
        } catch (e: SecurityException) {
            pendingLocationResult?.error("PERMISSION_DENIED", "Location permission not granted", null)
            pendingLocationResult = null
        }
    }

    // Heading (Compass)
    private fun getHeading(result: Result) {
        val accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        val magnetometer = sensorManager?.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        if (accelerometer == null || magnetometer == null) {
            result.error("UNAVAILABLE", "Compass sensors not available", null)
            return
        }

        val listener = object : SensorEventListener {
            private var hasAccelerometer = false
            private var hasMagnetometer = false

            override fun onSensorChanged(event: SensorEvent) {
                when (event.sensor.type) {
                    Sensor.TYPE_ACCELEROMETER -> {
                        System.arraycopy(event.values, 0, accelerometerReading, 0, 3)
                        hasAccelerometer = true
                    }
                    Sensor.TYPE_MAGNETIC_FIELD -> {
                        System.arraycopy(event.values, 0, magnetometerReading, 0, 3)
                        hasMagnetometer = true
                    }
                }

                if (hasAccelerometer && hasMagnetometer) {
                    sensorManager?.unregisterListener(this)

                    SensorManager.getRotationMatrix(rotationMatrix, null, accelerometerReading, magnetometerReading)
                    SensorManager.getOrientation(rotationMatrix, orientationAngles)

                    val azimuth = Math.toDegrees(orientationAngles[0].toDouble())
                    val heading = (azimuth + 360) % 360

                    val headingData = mapOf(
                        "trueHeading" to heading,
                        "magneticHeading" to heading,
                        "accuracy" to 15.0,
                        "timestamp" to System.currentTimeMillis()
                    )
                    result.success(headingData)
                }
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        sensorManager?.registerListener(listener, accelerometer, SensorManager.SENSOR_DELAY_UI)
        sensorManager?.registerListener(listener, magnetometer, SensorManager.SENSOR_DELAY_UI)
    }

    // Device Orientation
    private fun getDeviceOrientation(result: Result) {
        val rotationSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
            ?: sensorManager?.getDefaultSensor(Sensor.TYPE_GAME_ROTATION_VECTOR)

        if (rotationSensor == null) {
            result.error("UNAVAILABLE", "Rotation sensor not available", null)
            return
        }

        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                sensorManager?.unregisterListener(this)

                val rotationMatrix = FloatArray(9)
                SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)

                val orientation = FloatArray(3)
                SensorManager.getOrientation(rotationMatrix, orientation)

                val orientationData = mapOf(
                    "pitch" to Math.toDegrees(orientation[1].toDouble()),
                    "roll" to Math.toDegrees(orientation[2].toDouble()),
                    "yaw" to Math.toDegrees(orientation[0].toDouble()),
                    "timestamp" to System.currentTimeMillis()
                )
                result.success(orientationData)
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        sensorManager?.registerListener(listener, rotationSensor, SensorManager.SENSOR_DELAY_UI)
    }

    // Permissions
    private fun requestLocationPermission(result: Result) {
        if (hasLocationPermission()) {
            result.success(true)
            return
        }

        activity?.let {
            pendingPermissionResult = result
            ActivityCompat.requestPermissions(
                it,
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ),
                PERMISSION_REQUEST_CODE
            )
        } ?: run {
            result.error("NO_ACTIVITY", "Activity not available", null)
        }
    }

    private fun checkLocationPermission(result: Result) {
        result.success(hasLocationPermission())
    }

    private fun hasLocationPermission(): Boolean {
        return context?.let {
            ContextCompat.checkSelfPermission(it, Manifest.permission.ACCESS_FINE_LOCATION) ==
                    PackageManager.PERMISSION_GRANTED ||
                    ContextCompat.checkSelfPermission(it, Manifest.permission.ACCESS_COARSE_LOCATION) ==
                    PackageManager.PERMISSION_GRANTED
        } ?: false
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
            return true
        }
        return false
    }

    // Stream Handlers
    inner class LocationStreamHandler : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            locationEventSink = events
            startLocationUpdates()
        }

        override fun onCancel(arguments: Any?) {
            locationEventSink = null
            stopLocationUpdates()
        }
    }

    inner class HeadingStreamHandler : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            headingEventSink = events
            startHeadingUpdates()
        }

        override fun onCancel(arguments: Any?) {
            headingEventSink = null
            stopHeadingUpdates()
        }
    }

    inner class OrientationStreamHandler : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            orientationEventSink = events
            startOrientationUpdates()
        }

        override fun onCancel(arguments: Any?) {
            orientationEventSink = null
            stopOrientationUpdates()
        }
    }

    // Stream Control
    private fun startLocationUpdates() {
        if (!hasLocationPermission()) return

        val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 1000)
            .setWaitForAccurateLocation(false)
            .setMinUpdateIntervalMillis(500)
            .build()

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                locationResult.lastLocation?.let { location ->
                    val locationData = mapOf(
                        "latitude" to location.latitude,
                        "longitude" to location.longitude,
                        "altitude" to location.altitude,
                        "accuracy" to location.accuracy.toDouble(),
                        "timestamp" to location.time
                    )
                    locationEventSink?.success(locationData)
                }
            }
        }

        try {
            fusedLocationClient.requestLocationUpdates(
                locationRequest,
                locationCallback!!,
                Looper.getMainLooper()
            )
        } catch (_: SecurityException) {}
    }

    private fun stopLocationUpdates() {
        locationCallback?.let {
            try {
                fusedLocationClient.removeLocationUpdates(it)
            } catch (_: Exception) {}
        }
        locationCallback = null
    }

    private fun startHeadingUpdates() {
        val accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        val magnetometer = sensorManager?.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        if (accelerometer == null || magnetometer == null) return

        headingSensorListener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                when (event.sensor.type) {
                    Sensor.TYPE_ACCELEROMETER -> {
                        System.arraycopy(event.values, 0, accelerometerReading, 0, 3)
                    }
                    Sensor.TYPE_MAGNETIC_FIELD -> {
                        System.arraycopy(event.values, 0, magnetometerReading, 0, 3)
                    }
                }

                if (SensorManager.getRotationMatrix(rotationMatrix, null, accelerometerReading, magnetometerReading)) {
                    SensorManager.getOrientation(rotationMatrix, orientationAngles)

                    val azimuth = Math.toDegrees(orientationAngles[0].toDouble())
                    val heading = (azimuth + 360) % 360

                    val headingData = mapOf(
                        "trueHeading" to heading,
                        "magneticHeading" to heading,
                        "accuracy" to 15.0,
                        "timestamp" to System.currentTimeMillis()
                    )
                    headingEventSink?.success(headingData)
                }
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        sensorManager?.registerListener(headingSensorListener, accelerometer, SensorManager.SENSOR_DELAY_UI)
        sensorManager?.registerListener(headingSensorListener, magnetometer, SensorManager.SENSOR_DELAY_UI)
    }

    private fun stopHeadingUpdates() {
        headingSensorListener?.let {
            sensorManager?.unregisterListener(it)
        }
        headingSensorListener = null
    }

    private fun startOrientationUpdates() {
        val rotationSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
            ?: sensorManager?.getDefaultSensor(Sensor.TYPE_GAME_ROTATION_VECTOR)

        if (rotationSensor == null) return

        orientationSensorListener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                val rotationMatrix = FloatArray(9)
                SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)

                val orientation = FloatArray(3)
                SensorManager.getOrientation(rotationMatrix, orientation)

                val orientationData = mapOf(
                    "pitch" to Math.toDegrees(orientation[1].toDouble()),
                    "roll" to Math.toDegrees(orientation[2].toDouble()),
                    "yaw" to Math.toDegrees(orientation[0].toDouble()),
                    "timestamp" to System.currentTimeMillis()
                )
                orientationEventSink?.success(orientationData)
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        sensorManager?.registerListener(orientationSensorListener, rotationSensor, SensorManager.SENSOR_DELAY_UI)
    }

    private fun stopOrientationUpdates() {
        orientationSensorListener?.let {
            sensorManager?.unregisterListener(it)
        }
        orientationSensorListener = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        stopLocationUpdates()
        stopHeadingUpdates()
        stopOrientationUpdates()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeRequestPermissionsResultListener(this)
        activity = null
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeRequestPermissionsResultListener(this)
        activity = null
        activityBinding = null
    }
}
