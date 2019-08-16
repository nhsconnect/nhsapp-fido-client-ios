import Foundation
import CommonCrypto

class EncodingHelper {
    
    static func encodeInt( _ number:Int ) -> [UInt8] {
        var result: [UInt8] = Array()
        var _number: Int = number
        let mask8Bits = 0xFF
        
        for _ in ( 0 ..< 2 ) {
            result.append( UInt8(_number & mask8Bits))
            _number >>= 8
        }
        
        return result
    }
    
    static func encodeLong( _ number:Int32 ) -> [UInt8] {
        var result:[UInt8] = Array()
        var _number:Int32 = number
        let mask8Bits: Int32 = 0xFF
        
        for _ in ( 0 ..< 4 ) {
            result.append( UInt8( _number & mask8Bits ))
            _number >>= 8
        }
        
        return result
    }
    
    static func sha256(data : Data) -> [UInt8] {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.bindMemory(to: UInt8.self).baseAddress!, CC_LONG(data.count), &hash)
        }
        return hash
    }
}
