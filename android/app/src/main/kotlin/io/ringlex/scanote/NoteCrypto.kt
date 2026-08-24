package io.ringlex.scanote

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * Encrypts the contents of a protected note with a key that lives in the
 * Android Keystore and only comes out for an authenticated user.
 *
 * The key material never leaves the secure hardware, so a copy of the database
 * file is worth nothing on its own - which is the whole difference between
 * this and a PIN checked in the app.
 */
class NoteCrypto(private val activity: FragmentActivity) {
    companion object {
        private const val KEYSTORE = "AndroidKeyStore"
        private const val KEY_ALIAS = "io.ringlex.scanote.note_key"

        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val GCM_TAG_BITS = 128
        private const val IV_BYTES = 12

        /** Authentication that is good enough to release the key. */
        private const val ALLOWED_AUTHENTICATORS =
            BiometricManager.Authenticators.BIOMETRIC_STRONG or
                BiometricManager.Authenticators.DEVICE_CREDENTIAL

        /** Codes handed to Dart, which turns them into something readable. */
        const val ERROR_UNAVAILABLE = "unavailable"
        const val ERROR_CANCELLED = "cancelled"
        const val ERROR_KEY_LOST = "key_lost"
        const val ERROR_FAILED = "failed"
    }

    /** Whether this phone can protect a note at all. */
    fun isAvailable(): Boolean =
        BiometricManager.from(activity).canAuthenticate(ALLOWED_AUTHENTICATORS) ==
            BiometricManager.BIOMETRIC_SUCCESS

    fun encrypt(plainText: String, title: String, subtitle: String, cancel: String, callback: Callback) {
        runAuthenticated(Cipher.ENCRYPT_MODE, iv = null, title, subtitle, cancel, callback) { cipher ->
            val cipherText = cipher.doFinal(plainText.toByteArray(Charsets.UTF_8))

            // The iv is generated per encryption and is not a secret, so it
            // travels alongside what it produced.
            encode(cipher.iv, cipherText)
        }
    }

    fun decrypt(payload: String, title: String, subtitle: String, cancel: String, callback: Callback) {
        val parts = decode(payload)

        if (parts == null) {
            callback.onError(ERROR_FAILED, "The stored value is not readable")

            return
        }

        val (iv, cipherText) = parts

        runAuthenticated(Cipher.DECRYPT_MODE, iv, title, subtitle, cancel, callback) { cipher ->
            String(cipher.doFinal(cipherText), Charsets.UTF_8)
        }
    }

    private fun runAuthenticated(
        mode: Int,
        iv: ByteArray?,
        title: String,
        subtitle: String,
        cancel: String,
        callback: Callback,
        work: (Cipher) -> String,
    ) {
        if (!isAvailable()) {
            callback.onError(ERROR_UNAVAILABLE, "No biometrics or device credential is set up")

            return
        }

        val cipher = try {
            initCipher(mode, iv)
        } catch (error: Exception) {
            // A key the system threw away - after a factory reset, say - cannot
            // be brought back, and neither can what it encrypted.
            callback.onError(ERROR_KEY_LOST, error.message ?: "The key is gone")

            return
        }

        val prompt = BiometricPrompt(
            activity,
            androidx.core.content.ContextCompat.getMainExecutor(activity),
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    val authenticated = result.cryptoObject?.cipher

                    if (authenticated == null) {
                        callback.onError(ERROR_FAILED, "The prompt returned no cipher")

                        return
                    }

                    try {
                        callback.onSuccess(work(authenticated))
                    } catch (error: Exception) {
                        callback.onError(ERROR_FAILED, error.message ?: "The note could not be read")
                    }
                }

                override fun onAuthenticationError(code: Int, message: CharSequence) {
                    val isCancel = code == BiometricPrompt.ERROR_USER_CANCELED ||
                        code == BiometricPrompt.ERROR_NEGATIVE_BUTTON ||
                        code == BiometricPrompt.ERROR_CANCELED

                    callback.onError(
                        if (isCancel) ERROR_CANCELLED else ERROR_FAILED,
                        message.toString(),
                    )
                }
            },
        )

        val info = BiometricPrompt.PromptInfo.Builder()
            .setTitle(title)
            .setSubtitle(subtitle)
            .apply {
                // Below API 30 a device credential cannot back a crypto
                // operation, so those phones get a biometric prompt with a
                // plain cancel button.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    setAllowedAuthenticators(ALLOWED_AUTHENTICATORS)
                } else {
                    setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
                    setNegativeButtonText(cancel)
                }
            }
            .build()

        prompt.authenticate(info, BiometricPrompt.CryptoObject(cipher))
    }

    private fun initCipher(mode: Int, iv: ByteArray?): Cipher {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        val key = loadKey() ?: createKey()

        if (mode == Cipher.ENCRYPT_MODE) {
            cipher.init(Cipher.ENCRYPT_MODE, key)
        } else {
            cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(GCM_TAG_BITS, iv))
        }

        return cipher
    }

    private fun loadKey(): SecretKey? {
        val store = KeyStore.getInstance(KEYSTORE).apply { load(null) }

        return store.getKey(KEY_ALIAS, null) as? SecretKey
    }

    private fun createKey(): SecretKey {
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, KEYSTORE)

        val spec = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .setUserAuthenticationRequired(true)
            .apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    // Nought seconds: every single use needs its own
                    // authentication, rather than a window after one.
                    setUserAuthenticationParameters(0, KeyProperties.AUTH_BIOMETRIC_STRONG or KeyProperties.AUTH_DEVICE_CREDENTIAL)
                } else {
                    @Suppress("DEPRECATION")
                    setUserAuthenticationValidityDurationSeconds(-1)
                }

                // Adding a fingerprint leaves the notes readable. The other way
                // round would destroy them for good, which is a harsh answer to
                // somebody simply enrolling a second thumb.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    setInvalidatedByBiometricEnrollment(false)
                }
            }
            .build()

        generator.init(spec)

        return generator.generateKey()
    }

    private fun encode(iv: ByteArray, cipherText: ByteArray): String =
        Base64.encodeToString(iv + cipherText, Base64.NO_WRAP)

    /** Null when the stored text is not something [encode] produced. */
    private fun decode(payload: String): Pair<ByteArray, ByteArray>? {
        val raw = try {
            Base64.decode(payload, Base64.NO_WRAP)
        } catch (error: IllegalArgumentException) {
            return null
        }

        if (raw.size <= IV_BYTES) {
            return null
        }

        return raw.copyOfRange(0, IV_BYTES) to raw.copyOfRange(IV_BYTES, raw.size)
    }

    interface Callback {
        fun onSuccess(value: String)

        fun onError(code: String, message: String)
    }
}
