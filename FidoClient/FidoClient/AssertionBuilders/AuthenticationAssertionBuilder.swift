import Foundation
import CommonCrypto
import os.log
import BCryptSwift

class AuthenticationAssertionBuilder: FidoAssertionBuilder {
    let privateKey: SecKey

    init(privateKey: SecKey){
        self.privateKey = privateKey
    }
    
    @available(iOS 10.0, *)
    override func getAssertions(response: FidoResponse, aaid: String) throws -> String {
        do {
            var value = [UInt8]()
            var buffer = [UInt8]()
            
            try value = getAuthAssertion(response, aaid: aaid)
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_UAFV1_AUTH_ASSERTION.rawValue))
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
    
    func getDataToSign(_ response: FidoResponse, aaid: String) throws -> [UInt8] {
        
        do{
            var buffer = [UInt8]()
            
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_AAID.rawValue))
            var value: [UInt8] =  Array(aaid.utf8)
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_ASSERTION_INFO.rawValue))
            value = makeAssertionInfo()
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_AUTHENTICATOR_NONCE.rawValue))
            value = try createNonce()
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_FINAL_CHALLENGE.rawValue))
            value = try super.getFinalChallenge(response)
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_TRANSACTION_CONTENT_HASH.rawValue))
            buffer.append(contentsOf: EncodingHelper.encodeInt(0))
            
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_KEYID.rawValue))
            value = try getKeyID()
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_COUNTERS.rawValue))
            value = getCounters()
            buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
            buffer.append(contentsOf: value)
            
            return buffer
        } catch let error as FidoError {
            throw error
        }
    }
    
    func getCounters() -> [UInt8] {
        var buffer = [UInt8]()
        buffer += EncodingHelper.encodeInt(0)
        buffer += EncodingHelper.encodeInt(1)
        
        return buffer
    }
    
    func createNonce() throws -> [UInt8] {
        if let saltData = BCryptSwift.generateSalt().data(using: .utf8) {
            return EncodingHelper.sha256(data: saltData)
        }
        throw FidoError.encryptionError
    }
    
    @available(iOS 10.0, *)
    func getAuthAssertion(_ response: FidoResponse, aaid: String) throws -> [UInt8] {
        do {
            var buffer = [UInt8]()
            var length: Int = 0
            var value: [UInt8] = []
            
            value = try getDataToSign(response, aaid: aaid)
            length = value.count
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_UAFV1_SIGNED_DATA.rawValue))
            buffer.append(contentsOf: EncodingHelper.encodeInt(length))
            buffer.append(contentsOf: value)
            let dataToSign = buffer
            buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_SIGNATURE.rawValue))
            
            value = try FidoKeyManager().getSignature(dataToSign: dataToSign, key: privateKey)
            length = value.count
            buffer.append(contentsOf: EncodingHelper.encodeInt(length))
            buffer.append(contentsOf: value)
            
            return buffer
        } catch let error as FidoError {
            throw error
        }
    }
    
    func getKeyID() throws -> [UInt8] {
        do {
            let keyId = try UserDefaultsManager.getKeyID()
            
            return Array(keyId.utf8)
        } catch FidoError.keyRetrievalError{
            throw FidoError.keyRetrievalError
        }
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
        buffer += EncodingHelper.encodeInt(AlgAndEncodingEnum.UAF_ALG_SIGN_SECP256R1_ECDSA_SHA256_DER.rawValue)
        
        return buffer
    }
}

