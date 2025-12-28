package jp.landingapps.geo_finder

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import org.mockito.Mockito

internal class GeoFinderPluginTest {
  @Test
  fun onMethodCall_checkLocationPermission_returnsBoolean() {
    val plugin = GeoFinderPlugin()

    val call = MethodCall("checkLocationPermission", null)
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
    plugin.onMethodCall(call, mockResult)

    // Since context is null, it should return false
    Mockito.verify(mockResult).success(false)
  }
}
