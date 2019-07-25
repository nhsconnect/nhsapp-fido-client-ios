import Foundation
import LocalAuthentication

class FidoAssertionBuilder {
    
    let vendorAssignedVersion: UInt8 = 0x0
    let authenticationMode: UInt8 = 0x1
    
    @available(iOS 10.0, *)
    func getAssertions(response: FidoResponse, aaid: String) throws -> String{
        preconditionFailure("This method must be implemented in a derived class")
    }
    
    func getFinalChallenge(_ response: FidoResponse) throws ->  [UInt8] {
        let finalChallengeParams = response.fcParams
        
        if let data = finalChallengeParams.data(using: .utf8) {
            return EncodingHelper.sha256(data: data)
        }
        
        throw FidoError.parsingError
    }
    
}
