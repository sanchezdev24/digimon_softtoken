import UIKit
import Flutter
import CommonCrypto

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("Could not get FlutterViewController")
        }
        
        let cryptoChannel = FlutterMethodChannel(
            name: "crypto_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        cryptoChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "decrypt":
                guard let args = call.arguments as? [String: Any],
                      let encryptedData = args["encryptedData"] as? String,
                      let key = args["key"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "encryptedData and key are required", details: nil))
                    return
                }
                
                do {
                    let decryptedData = try self?.decryptAES(encryptedData: encryptedData, key: key)
                    result(decryptedData)
                } catch {
                    result(FlutterError(code: "DECRYPT_ERROR", message: "Failed to decrypt: \(error.localizedDescription)", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func decryptAES(encryptedData: String, key: String) throws -> String {
        print("iOSCrypto: Starting decryption...")
        print("iOSCrypto: EncryptedData: \(encryptedData)")
        print("iOSCrypto: Key: \(key)")
        
        // Detectar formato base64 o hex
        let isBase64Format = encryptedData.contains("==") ||
                           encryptedData.range(of: "^[A-Za-z0-9+/=:]+$", options: .regularExpression) != nil
        
        let (iv, encrypted): (Data, Data)
        
        if isBase64Format {
            print("iOSCrypto: Detected Base64 format")
            (iv, encrypted) = try parseBase64Format(encryptedData: encryptedData)
        } else {
            print("iOSCrypto: Detected Hex format")
            (iv, encrypted) = try parseHexFormat(encryptedData: encryptedData)
        }
        
        print("iOSCrypto: IV length: \(iv.count)")
        print("iOSCrypto: Encrypted length: \(encrypted.count)")
        
        // Manejar diferentes tamaños de IV
        let adjustedIv: Data
        switch iv.count {
        case 12:
            print("iOSCrypto: Padding IV from 12 to 16 bytes")
            adjustedIv = iv + Data(repeating: 0, count: 4) // Rellenar con ceros
        case 16:
            print("iOSCrypto: IV is correct size (16 bytes)")
            adjustedIv = iv
        default:
            throw NSError(domain: "CryptoError", code: 1, userInfo: [NSLocalizedDescriptionKey: "IV must be 12 or 16 bytes, got \(iv.count)"])
        }
        
        // Generar clave usando SHA-256
        guard let keyData = key.data(using: .utf8) else {
            throw NSError(domain: "CryptoError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid key format"])
        }
        
        let keyBytes = keyData.sha256()
        print("iOSCrypto: Key bytes length: \(keyBytes.count)")
        
        // Descifrar usando AES-256-CBC
        let decryptedData = try aesDecrypt(data: encrypted, key: keyBytes, iv: adjustedIv)
        
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw NSError(domain: "CryptoError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to convert decrypted data to string"])
        }
        
        print("iOSCrypto: Decryption successful, result length: \(decryptedString.count)")
        return decryptedString
    }
    
    private func parseBase64Format(encryptedData: String) throws -> (Data, Data) {
        let parts = encryptedData.components(separatedBy: ":")
        guard parts.count == 2 else {
            throw NSError(domain: "CryptoError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid base64 encrypted data format"])
        }
        
        guard let iv = Data(base64Encoded: parts[0]),
              let encrypted = Data(base64Encoded: parts[1]) else {
            throw NSError(domain: "CryptoError", code: 5, userInfo: [NSLocalizedDescriptionKey: "Invalid base64 format"])
        }
        
        return (iv, encrypted)
    }
    
    private func parseHexFormat(encryptedData: String) throws -> (Data, Data) {
        let parts = encryptedData.components(separatedBy: ":")
        guard parts.count == 2 else {
            throw NSError(domain: "CryptoError", code: 6, userInfo: [NSLocalizedDescriptionKey: "Invalid hex encrypted data format"])
        }
        
        guard let iv = Data(hex: parts[0]),
              let encrypted = Data(hex: parts[1]) else {
            throw NSError(domain: "CryptoError", code: 7, userInfo: [NSLocalizedDescriptionKey: "Invalid hex format"])
        }
        
        return (iv, encrypted)
    }
    
    private func aesDecrypt(data: Data, key: Data, iv: Data) throws -> Data {
        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData = Data(count: cryptLength)
        
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { keyBytes in
                    iv.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.bindMemory(to: UInt8.self).baseAddress,
                            key.count,
                            ivBytes.bindMemory(to: UInt8.self).baseAddress,
                            dataBytes.bindMemory(to: UInt8.self).baseAddress,
                            data.count,
                            cryptBytes.bindMemory(to: UInt8.self).baseAddress,
                            cryptLength,
                            &numBytesDecrypted
                        )
                    }
                }
            }
        }
        
        guard cryptStatus == kCCSuccess else {
            throw NSError(domain: "CryptoError", code: 8, userInfo: [NSLocalizedDescriptionKey: "AES decryption failed"])
        }
        
        cryptData.removeSubrange(numBytesDecrypted..<cryptData.count)
        return cryptData
    }
}

extension Data {
    init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        
        for i in 0..<len {
            let start = hex.index(hex.startIndex, offsetBy: i * 2)
            let end = hex.index(start, offsetBy: 2)
            let bytes = hex[start..<end]
            
            if let byte = UInt8(bytes, radix: 16) {
                data.append(byte)
            } else {
                return nil
            }
        }
        
        self = data
    }
    
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
}
