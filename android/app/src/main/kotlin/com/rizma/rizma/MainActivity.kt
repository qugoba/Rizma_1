package com.rizma.rizma

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.Inet4Address
import java.net.NetworkInterface

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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
                    "localAddresses" -> result.success(localAddresses(cm))
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
                    "sdkInt" -> result.success(Build.VERSION.SDK_INT)
                    else -> result.notImplemented()
                }
            }
    }

    private fun localAddresses(cm: ConnectivityManager): List<String> {
        val out = mutableListOf<String>()
        try {
            @Suppress("DEPRECATION")
            for (n in cm.allNetworks) {
                val caps = cm.getNetworkCapabilities(n) ?: continue
                if (!caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) &&
                    !caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)
                ) continue
                val lp = cm.getLinkProperties(n) ?: continue
                for (la in lp.linkAddresses) {
                    val a = la.address
                    if (a is Inet4Address) {
                        out.add("wifi|${lp.interfaceName ?: ""}|${a.hostAddress}/${la.prefixLength}")
                    }
                }
            }
        } catch (e: Exception) {
            out.add("error|wifi|${e.javaClass.simpleName}")
        }
        try {
            for (i in NetworkInterface.getNetworkInterfaces()?.toList().orEmpty()) {
                if (!i.isUp || i.isLoopback) continue
                for (ia in i.interfaceAddresses) {
                    val a = ia.address
                    if (a is Inet4Address) {
                        out.add("iface|${i.name}|${a.hostAddress}/${ia.networkPrefixLength}")
                    }
                }
            }
        } catch (e: Exception) {
            out.add("error|iface|${e.javaClass.simpleName}")
        }
        try {
            val wm = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            @Suppress("DEPRECATION")
            val ip = wm.connectionInfo?.ipAddress ?: 0
            if (ip != 0) {
                out.add("wm|wlan|${ip and 0xff}.${ip shr 8 and 0xff}.${ip shr 16 and 0xff}.${ip shr 24 and 0xff}")
            }
        } catch (e: Exception) {
            out.add("error|wm|${e.javaClass.simpleName}")
        }
        return out
    }

    @Suppress("DEPRECATION")
    private fun wifiNetwork(cm: ConnectivityManager) = cm.allNetworks.firstOrNull { n ->
        cm.getNetworkCapabilities(n)?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true
    }
}
