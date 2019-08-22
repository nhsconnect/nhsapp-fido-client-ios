import Foundation
import LocalAuthentication
import CommonCrypto
import os.log
import BCryptSwift

class RegistrationAssertionBuilder: FidoAssertionBuilder{
    let keyIDPrefix: String
    let keyPair: KeyPair
    init(keyPair: KeyPair, keyIDPrefix: String) {
        self.keyPair = keyPair
        self.keyIDPrefix = keyIDPrefix
    }
    
    @available(iOS 10.0, *)
    override func getAssertions(response: FidoResponse, aaid: String) throws -> String {
        var value = [UInt8]()
        var buffer = [UInt8]()
        do {
            try value = getRegistrationAssertion(response, aaid: aaid)
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_UAFV1_REG_ASSERTION.rawValue))
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            try value = ExtensionAssertionBuilder().getExtensionData()
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_EXTENSION.rawValue))
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            return Data(bytes: buffer, count: buffer.count).base64EncodedDataRFC4648()
        } catch let error as FidoError {
            throw error
        }
    }
    
    @available(iOS 10.0, *)
    func getRegistrationAssertion(_ response: FidoResponse, aaid: String) throws -> [UInt8] {
        do {
            var buffer = [UInt8]()
            var value: [UInt8] = try getSignedData(response, aaid: aaid)
            var length: Int = value.count
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_UAFV1_KRD.rawValue))
            buffer.append(contentsOf: EncodingHelper.encodeInt(length))
            buffer.append(contentsOf: value)
            
            let signedDataValue = buffer
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_ATTESTATION_BASIC_SURROGATE.rawValue))
            try value = getAttestationBasicSurrogate(signedDataValue)
            length = value.count
            buffer.append(contentsOf: EncodingHelper.encodeInt(length))
            buffer.append(contentsOf: value)
            
            return buffer
        } catch let error as FidoError {
            throw error
        }
    }
    
    @available(iOS 10.0, *)
    func getAttestationBasicSurrogate(_ dataToSign: [UInt8]) throws -> [UInt8] {
        do {
            var buffer = [UInt8]()
            var value = [UInt8]()
            
            try value = FidoKeyManager().getSignature(dataToSign: dataToSign, key: keyPair.privKey)
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_SIGNATURE.rawValue))
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            return buffer
        } catch let error as FidoError {
            throw error
        }
    }
    
   
    @available(iOS 10.0, *)
    func getSignedData(_ response: FidoResponse, aaid: String) throws -> [UInt8] {
        do {
            var buffer = [UInt8]()
            
            
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_AAID.rawValue))
            var value: [UInt8] =  Array(aaid.utf8)
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_ASSERTION_INFO.rawValue))
            value = makeAssertionInfo()
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_FINAL_CHALLENGE.rawValue))
            value = try super.getFinalChallenge(response)
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_KEYID.rawValue))
            value = createKeyID()
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_COUNTERS.rawValue))
            value = getCounters()
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_PUB_KEY.rawValue))
            value = try getPubKeyID()
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            return buffer
        } catch let error as FidoError {
            throw error
        }
    }
    
    @available(iOS 10.0, *)
    func getPubKeyID() throws -> [UInt8] {
        if let keyData = SecKeyCopyExternalRepresentation(keyPair.pubKey, nil) as Data?{
            return [UInt8](keyData)
        }
        throw FidoError.keyRetrievalError
    }
    
    func getCounters() -> [UInt8] {
        var buffer = [UInt8]()
        buffer += EncodingHelper.encodeInt(0)
        buffer += EncodingHelper.encodeInt(1)
        buffer += EncodingHelper.encodeInt(0)
        buffer += EncodingHelper.encodeInt(1)
        
        return buffer
    }
        
    
    func createKeyID() -> [UInt8]{
        let salt = BCryptSwift.generateSalt()
        
        return createKeyIDWith(salt)
    }
    
    func createKeyIDWith(_ salt: String) -> [UInt8] {
        let saltByteArray: [UInt8] = Array(salt.utf8)
        let data = NSData(bytes: saltByteArray, length: saltByteArray.count)
        var keyID = keyIDPrefix + data.base64EncodedDataRFC4648()
        UserDefaultsManager.saveKeyID(keyID)
        
        return Array(keyID.utf8)
    }
    
    func makeAssertionInfo() -> [UInt8] {
        //2 bytes - vendor; 1 byte Authentication Mode; 2 bytes Sig Alg; 2 bytes Pub Key Alg
        var buffer = [UInt8]()
        // 2 bytes - vendor assigned version
        buffer.append(vendorAssignedVersion)
        buffer.append(vendorAssignedVersion)
        // 1 byte Authentication Mode;
        buffer.append(authenticationMode)
        // 2 bytes Sig Alg
        buffer += EncodingHelper.encodeInt(AlgAndEncodingEnum.UAF_ALG_SIGN_SECP256R1_ECDSA_SHA256_RAW.rawValue) //this may be the same as below
        // 2 bytes Pub Key Alg
        buffer += EncodingHelper.encodeInt(AlgAndEncodingEnum.UAF_ALG_KEY_ECC_X962_RAW.rawValue)
        
        return buffer
    }
}
