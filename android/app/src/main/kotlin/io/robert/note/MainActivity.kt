package io.robert.note

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * A FragmentActivity rather than the plain FlutterActivity, because
 * BiometricPrompt only works from one.
 */
class MainActivity: FlutterFragmentActivity() {
    private companion object {
        const val CHANNEL = "io.robert.note/notifications"
        const val OPEN_NOTIFICATION_SETTINGS = "openNotificationSettings"

        const val SHARE_CHANNEL = "io.robert.note/share"
        const val CONSUME_SHARED_TEXT = "consumeSharedText"

        const val CRYPTO_CHANNEL = "io.robert.note/crypto"
        const val IS_PROTECTION_AVAILABLE = "isProtectionAvailable"
        const val ENCRYPT = "encrypt"
        const val DECRYPT = "decrypt"

        const val KEY_TEXT = "text"
        const val KEY_SUBJECT = "subject"
    }

   
    private var pendingShare: Map<String, String?>? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)

        pendingShare = readSharedText(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        setIntent(intent)
        readSharedText(intent)?.let { pendingShare = it }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                OPEN_NOTIFICATION_SETTINGS -> result.success(openNotificationSettings())
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                CONSUME_SHARED_TEXT -> {
                    result.success(pendingShare)
                    pendingShare = null
                }
                else -> result.notImplemented()
            }
        }

        val crypto = NoteCrypto(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CRYPTO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                IS_PROTECTION_AVAILABLE -> result.success(crypto.isAvailable())
                ENCRYPT, DECRYPT -> {
                    // The prompt is asynchronous, so the result is only
                    // answered once the user has dealt with it.
                    val callback = object : NoteCrypto.Callback {
                        override fun onSuccess(value: String) = result.success(value)

                        override fun onError(code: String, message: String) =
                            result.error(code, message, null)
                    }

                    val value = call.argument<String>("value").orEmpty()
                    val title = call.argument<String>("title").orEmpty()
                    val subtitle = call.argument<String>("subtitle").orEmpty()
                    val cancel = call.argument<String>("cancel").orEmpty()

                    if (call.method == ENCRYPT) {
                        crypto.encrypt(value, title, subtitle, cancel, callback)
                    } else {
                        crypto.decrypt(value, title, subtitle, cancel, callback)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /** Null for anything that is not a share carrying usable text. */
    private fun readSharedText(intent: Intent?): Map<String, String?>? {
        if (intent?.action != Intent.ACTION_SEND || intent.type != "text/plain") {
            return null
        }

        val text = intent.getStringExtra(Intent.EXTRA_TEXT)

        if (text.isNullOrBlank()) {
            return null
        }

        return mapOf(
            KEY_TEXT to text,
            KEY_SUBJECT to intent.getStringExtra(Intent.EXTRA_SUBJECT),
        )
    }

    /**
     * Android O and up has a page for the app's notifications alone. Older
     * versions only have the app details, which is where they live there.
     */
    private fun openNotificationSettings(): Boolean {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                .setData(Uri.fromParts("package", packageName, null))
        }

        return try {
            startActivity(intent)
            true
        } catch (error: android.content.ActivityNotFoundException) {
            false
        }
    }
}
