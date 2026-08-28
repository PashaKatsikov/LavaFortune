package com.lavafortune.lavafortunegame

import android.app.Activity
import android.content.Intent
import android.content.res.Configuration
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // [FORGE] Rotated per project by tool/forge/mint.dart. Keep in sync
    // with lib/caldera/pads/viewport.dart → `MethodChannel('...')`.
    private val channelName = "magmahole/upload"
    private val pickRequest = 0x6B21
    private var pendingResult: MethodChannel.Result? = null
    private var pipe: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
        // Window flags are set once. Re-applying them on focus or
        // rotation triggers another insets dispatch, and every extra
        // dispatch is one more visible re-layout of the WebView.
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING)
        WindowInsetsControllerCompat(window, window.decorView).systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        cloakBars()
        bindImePulse()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) cloakBars()
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        // Report the rotated cutout as early as possible so Dart can
        // settle the gutter in one step rather than several.
        window.decorView.post {
            cloakBars()
            pipe?.invokeMethod("chromePulse", samplePane())
        }
    }

    private fun cloakBars() {
        val root = window.decorView
        val now = ViewCompat.getRootWindowInsets(root)
        val imeUp = now != null && now.isVisible(WindowInsetsCompat.Type.ime())
        // While the IME is up the nav bar stays as an overlay: hiding
        // it there cancels the keyboard and zeroes the IME insets.
        val wanted = if (imeUp) {
            WindowInsetsCompat.Type.statusBars()
        } else {
            WindowInsetsCompat.Type.statusBars() or
                WindowInsetsCompat.Type.navigationBars()
        }
        val alreadyHidden = now != null &&
            !now.isVisible(WindowInsetsCompat.Type.statusBars()) &&
            (imeUp || !now.isVisible(WindowInsetsCompat.Type.navigationBars()))
        if (alreadyHidden) return
        WindowInsetsControllerCompat(window, root).hide(wanted)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pipe = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        pipe?.setMethodCallHandler { call, result ->
            when (call.method) {
                "pick" -> {
                    val many = call.argument<Boolean>("multiple") ?: false
                    val types = call.argument<List<String>>("mimeTypes") ?: emptyList()
                    openChooser(many, types, result)
                }
                "readPane" -> result.success(samplePane())
                else -> result.notImplemented()
            }
        }
    }

    private fun toDip(px: Int): Double {
        val scale = resources.displayMetrics.density.toDouble()
        return if (scale <= 0.0) 0.0 else px / scale
    }

    private var lastImeDip = -1.0

    private fun samplePane(): HashMap<String, Double> {
        val now = ViewCompat.getRootWindowInsets(window.decorView)
        val keyboard = now?.getInsets(WindowInsetsCompat.Type.ime())?.bottom ?: 0
        val notch = now?.getInsets(WindowInsetsCompat.Type.displayCutout())
        return hashMapOf(
            "ime" to toDip(keyboard),
            "cutLeft" to toDip(notch?.left ?: 0),
            "cutTop" to toDip(notch?.top ?: 0),
            "cutRight" to toDip(notch?.right ?: 0),
        )
    }

    private fun bindImePulse() {
        val host = findViewById<View>(android.R.id.content) ?: return
        ViewCompat.setWindowInsetsAnimationCallback(
            host,
            object : WindowInsetsAnimationCompat.Callback(
                WindowInsetsAnimationCompat.Callback.DISPATCH_MODE_CONTINUE_ON_SUBTREE,
            ) {
                override fun onProgress(
                    insets: WindowInsetsCompat,
                    runningAnimations: MutableList<WindowInsetsAnimationCompat>,
                ): WindowInsetsCompat = insets

                override fun onEnd(animation: WindowInsetsAnimationCompat) {
                    val pane = samplePane()
                    val ime = pane["ime"] ?: 0.0
                    if (kotlin.math.abs(ime - lastImeDip) < 1.0) return
                    lastImeDip = ime
                    runOnUiThread {
                        pipe?.invokeMethod("chromePulse", pane)
                    }
                }
            },
        )
    }

    private fun openChooser(
        multiple: Boolean,
        mimes: List<String>,
        result: MethodChannel.Result,
    ) {
        pendingResult?.success(emptyList<String>())
        pendingResult = result

        val valid = mimes.filter { it.contains("/") }
        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, multiple)
            when {
                valid.isEmpty() -> type = "*/*"
                valid.size == 1 -> type = valid[0]
                else -> {
                    type = "*/*"
                    putExtra(Intent.EXTRA_MIME_TYPES, valid.toTypedArray())
                }
            }
        }

        try {
            startActivityForResult(Intent.createChooser(intent, null), pickRequest)
        } catch (e: Exception) {
            pendingResult = null
            result.success(emptyList<String>())
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != pickRequest) return

        val result = pendingResult
        pendingResult = null
        if (result == null) return

        if (resultCode != Activity.RESULT_OK || data == null) {
            result.success(emptyList<String>())
            return
        }

        val uris = ArrayList<String>()
        val clip = data.clipData
        if (clip != null) {
            for (i in 0 until clip.itemCount) {
                uris.add(clip.getItemAt(i).uri.toString())
            }
        } else {
            data.data?.let { uris.add(it.toString()) }
        }
        result.success(uris)
    }
}
