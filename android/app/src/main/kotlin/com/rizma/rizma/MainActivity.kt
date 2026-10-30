package com.rizma.rizma

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.Inet4Address

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // النقل من هاتف لهاتف على Wi-Fi (ADR 003). شبكة Wi-Fi أو هوتسبوت بلا
        // إنترنت لا تصبح شبكة أندرويد الافتراضية، فتذهب الاتصالات عبر بيانات
        // الهاتف ولا تصل للهاتف الآخر. نربط التطبيق بالـ Wi-Fi ما دامت شاشة
        // الاستلام مفتوحة، ونفكّه بعدها.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rizma/network")
            .setMethodCallHandler { call, result ->
                val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                when (call.method) {
                    "bindWifi" -> {
                        val wifi = wifiNetwork(cm)
                        result.success(
                            Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                                wifi != null && cm.bindProcessToNetwork(wifi)
                        )
                    }
                    "unbind" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            cm.bindProcessToNetwork(null)
                        }
                        result.success(true)
                    }
                    "wifiAddresses" -> {
                        val wifi = wifiNetwork(cm)
                        val addresses = wifi?.let { cm.getLinkProperties(it) }
                            ?.linkAddresses
                            ?.map { it.address }
                            ?.filterIsInstance<Inet4Address>()
                            ?.mapNotNull { it.hostAddress }
                            ?: emptyList()
                        result.success(addresses)
                    }
                    // «أرسل على Wi-Fi»: الشاشة لا تنطفئ، فكثير من الهواتف يقطع شبكة
                    // التطبيق حين تنقفل الشاشة فيتوقف الإرسال.
                    "keepScreenOn" -> {
                        val on = call.arguments as? Boolean ?: false
                        runOnUiThread {
                            if (on) {
                                window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            } else {
                                window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            }
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @Suppress("DEPRECATION")
    private fun wifiNetwork(cm: ConnectivityManager) = cm.allNetworks.firstOrNull { n ->
        cm.getNetworkCapabilities(n)?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true
    }
}
