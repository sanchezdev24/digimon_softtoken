package com.stratplus.digimon_softtoken

import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec
import javax.crypto.spec.IvParameterSpec
import java.security.MessageDigest
import java.security.SecureRandom
import java.nio.charset.StandardCharsets
import java.util.Base64

class MainActivity: FlutterActivity() {
    private val CHANNEL = "crypto_channel"

    @RequiresApi(Build.VERSION_CODES.O)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "decrypt" -> {
                    val encryptedData = call.argument<String>("encryptedData")
                    val key = call.argument<String>("key")

                    if (encryptedData != null && key != null) {
                        try {
                            val decryptedData = decryptAES(encryptedData, key)
                            result.success(decryptedData)
                        } catch (e: Exception) {
                            result.error("DECRYPT_ERROR", "Failed to decrypt: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "encryptedData and key are required", null)
                    }
                }
                "encrypt" -> {
                    val data = call.argument<String>("data")
                    val key = call.argument<String>("key")

                    if (data != null && key != null) {
                        try {
                            val encryptedData = encryptAES(data, key)
                            result.success(encryptedData)
                        } catch (e: Exception) {
                            result.error("ENCRYPT_ERROR", "Failed to encrypt: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "data and key are required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun decryptAES(encryptedData: String, key: String): String {
        println("AndroidCrypto: Starting decryption...")
        println("AndroidCrypto: EncryptedData: $encryptedData")
        println("AndroidCrypto: Key: $key")

        try {
            // Detectar si es formato base64:base64 o hex:hex
            val isBase64Format = encryptedData.contains("==") ||
                    encryptedData.matches(Regex("^[A-Za-z0-9+/=:]+$"))

            val (iv, encrypted) = if (isBase64Format) {
                println("AndroidCrypto: Detected Base64 format")
                parseBase64Format(encryptedData)
            } else {
                println("AndroidCrypto: Detected Hex format")
                parseHexFormat(encryptedData)
            }

            println("AndroidCrypto: IV length: ${iv.size}")
            println("AndroidCrypto: Encrypted length: ${encrypted.size}")

            // Manejar diferentes tamaños de IV
            val adjustedIv = when (iv.size) {
                12 -> {
                    println("AndroidCrypto: Padding IV from 12 to 16 bytes")
                    iv + ByteArray(4) { 0 }
                }
                16 -> {
                    println("AndroidCrypto: IV is correct size (16 bytes)")
                    iv
                }
                else -> {
                    println("AndroidCrypto: Unexpected IV size: ${iv.size}")
                    throw IllegalArgumentException("IV must be 12 or 16 bytes, got ${iv.size}")
                }
            }

            // Generar clave usando SHA-256
            val keyBytes = MessageDigest.getInstance("SHA-256").digest(key.toByteArray(StandardCharsets.UTF_8))
            println("AndroidCrypto: Key bytes length: ${keyBytes.size}")

            // Descifrar usando AES-256-CBC
            val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
            val secretKey = SecretKeySpec(keyBytes, "AES")
            val ivSpec = IvParameterSpec(adjustedIv)

            cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec)
            val decryptedBytes = cipher.doFinal(encrypted)

            val result = String(decryptedBytes, StandardCharsets.UTF_8)
            println("AndroidCrypto: Decryption successful, result length: ${result.length}")

            return result

        } catch (e: Exception) {
            println("AndroidCrypto: Error during decryption: ${e.message}")
            e.printStackTrace()
            throw e
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun encryptAES(data: String, key: String): String {
        println("AndroidCrypto: Starting encryption...")
        println("AndroidCrypto: Data: $data")
        println("AndroidCrypto: Key: $key")

        try {
            // Generar IV aleatorio de 16 bytes
            val random = SecureRandom()
            val iv = ByteArray(16)
            random.nextBytes(iv)

            println("AndroidCrypto: Generated IV length: ${iv.size}")

            // Generar clave usando SHA-256
            val keyBytes = MessageDigest.getInstance("SHA-256").digest(key.toByteArray(StandardCharsets.UTF_8))
            println("AndroidCrypto: Key bytes length: ${keyBytes.size}")

            // Cifrar usando AES-256-CBC
            val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
            val secretKey = SecretKeySpec(keyBytes, "AES")
            val ivSpec = IvParameterSpec(iv)

            cipher.init(Cipher.ENCRYPT_MODE, secretKey, ivSpec)
            val encryptedBytes = cipher.doFinal(data.toByteArray(StandardCharsets.UTF_8))

            println("AndroidCrypto: Encrypted bytes length: ${encryptedBytes.size}")

            // Convertir a formato base64:base64
            val ivBase64 = Base64.getEncoder().encodeToString(iv)
            val encryptedBase64 = Base64.getEncoder().encodeToString(encryptedBytes)

            val result = "$ivBase64:$encryptedBase64"
            println("AndroidCrypto: Encryption successful: $result")

            return result

        } catch (e: Exception) {
            println("AndroidCrypto: Error during encryption: ${e.message}")
            e.printStackTrace()
            throw e
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun parseBase64Format(encryptedData: String): Pair<ByteArray, ByteArray> {
        val parts = encryptedData.split(":")
        if (parts.size != 2) {
            throw IllegalArgumentException("Invalid base64 encrypted data format")
        }

        val iv = Base64.getDecoder().decode(parts[0])
        val encrypted = Base64.getDecoder().decode(parts[1])

        return Pair(iv, encrypted)
    }

    private fun parseHexFormat(encryptedData: String): Pair<ByteArray, ByteArray> {
        val parts = encryptedData.split(":")
        if (parts.size != 2) {
            throw IllegalArgumentException("Invalid hex encrypted data format")
        }

        val iv = hexToBytes(parts[0])
        val encrypted = hexToBytes(parts[1])

        return Pair(iv, encrypted)
    }

    private fun hexToBytes(hex: String): ByteArray {
        val len = hex.length
        val data = ByteArray(len / 2)
        for (i in 0 until len step 2) {
            data[i / 2] = ((Character.digit(hex[i], 16) shl 4) + Character.digit(hex[i + 1], 16)).toByte()
        }
        return data
    }
}