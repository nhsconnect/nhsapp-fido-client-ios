import Foundation
import os.log

class FidoKeyManager {
    
    @available(iOS 10.0, *)
    func generateKeyPair(privateKeyLabel: String) throws -> KeyPair {
        deletePrivateKey(privateKeyLabel: privateKeyLabel)
        let attributes = try getAttributes(privateKeyLabel: privateKeyLabel)
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        if let publicKey = SecKeyCopyPublicKey(privateKey) {
            return  KeyPair(pubKey: publicKey, privKey: privateKey)
        }
        
        throw FidoError.invalidBiometrics
        
    }
    
    func deletePrivateKey(privateKeyLabel: String) {
        SecItemDelete(getQuery(privateKeyLabel: privateKeyLabel) as CFDictionary)
    }
    
    func getPrivateKey(privateKeyLabel: String) throws -> SecKey {
        var item: CFTypeRef?
        SecItemCopyMatching(getQuery(privateKeyLabel: privateKeyLabel) as CFDictionary, &item)
        
        if item != nil {
            return item as! SecKey
        }
        throw FidoError.keyRetrievalError
    }
    
    @available(iOS 10.0, *)
    func getSignature(dataToSign: [UInt8], key: SecKey) throws -> [UInt8] {
        let data = Data(bytes: dataToSign, count: dataToSign.count)
        
        guard let signData = SecKeyCreateSignature(key, SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256, data as CFData, nil) else {
            os_log("priv ECC error signing", log: OSLog.default, type: .error)
            throw FidoError.invalidBiometrics
        }
        let signedData = signData as Data
        
        return  [UInt8](signedData)
    }
    
    func getQuery(privateKeyLabel: String) -> [String: Any]{
        let keyQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrLabel as String: privateKeyLabel,
            kSecReturnRef as String: true,
            ]
        return keyQuery
    }
    
    func getAttributes(privateKeyLabel: String) throws -> [String: Any] {
        return [
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrLabel as String: privateKeyLabel,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String:
                [
                    kSecAttrIsPermanent as String: true,
                    kSecAttrAccessControl as String: try getAccessControlSettings()
                ]
        ]
    }
    
    func getAccessControlSettings() throws -> SecAccessControl {
        var biometricType : SecAccessControlCreateFlags = .touchIDCurrentSet
        
        if #available(iOS 11.3, *) {
            biometricType = .biometryCurrentSet
        }
        
        if let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                            [.privateKeyUsage, biometricType], nil) {
            return access
        }
        
        throw FidoError.invalidBiometrics
    }
    
}
