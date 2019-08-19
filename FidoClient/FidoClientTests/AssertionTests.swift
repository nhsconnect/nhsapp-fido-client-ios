import XCTest
import Foundation
import LocalAuthentication
@testable import FidoClient

@available(iOS 10.0, *)
class AssertionTests: XCTestCase {
    
    var registrationAssertionBuilder: RegistrationAssertionBuilder?
    
    
    override func setUp() {
        super.setUp()
        var keyPairAttr = [NSObject: NSObject]()
        keyPairAttr[kSecAttrKeyType] = kSecAttrKeyTypeRSA
        keyPairAttr[kSecAttrKeySizeInBits] = 2048 as NSObject
        
        let mockKey = SecKeyCreateRandomKey(keyPairAttr as CFDictionary, nil )
        let keyPair: KeyPair = KeyPair(pubKey: mockKey!, privKey: mockKey!)
        
        registrationAssertionBuilder = RegistrationAssertionBuilder(keyPair: keyPair)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_getFC() throws{
        do {
            let header: OperationHeader = OperationHeader(Version(major: 1,minor: 0), Operation.Reg, "ValidAppId")
            let regResponse: FidoResponse = FidoResponse(header: header, fcParams: "fcParams", assertions: [])
            let fc = try registrationAssertionBuilder!.getFinalChallenge(regResponse)
            XCTAssert(fc == [40,13,43,222,56,205,19,208,16,117,183,186,7,245,199,24,252,104,130,76,243,116,105,59,56,144, 237, 199,80,33,245,58])
        } catch let error as FidoError {
            throw error
        }
        
    }
    
    func test_getKeyID(){
        let keyID = registrationAssertionBuilder!.createKeyIDWith("aSalt")
        XCTAssert(keyID == Array("nhs-app-key-YVNhbHQ=".utf8))
    }
    
    func test_makeAssertionInfo(){
        let assertionInfo = registrationAssertionBuilder!.makeAssertionInfo()
        XCTAssert([0,0,1,1,0,0,1] == assertionInfo)
    }
    
    func test_getCounters(){
        let counters = registrationAssertionBuilder?.getCounters()
        XCTAssert([0,0,1,0,0,0,1,0] == counters)
    }
    
    func test_getUVMData() throws {
        do {
        let uvmData = try MockAssertionBuilder().getUVMData()
        XCTAssert([1,0,0,0,10,0,4,0] == uvmData)
        } catch let error as FidoError {
            throw error
        }
    }
    
    func test_getExtensions() throws {
        do {
        let extensions = try MockAssertionBuilder().getExtensionData()
        XCTAssert([19,46,12,0,102,105,100,111,46,117,97,102,46,117,118,109,20,46,8,0,1,0,0,0,10,0,4,0] == extensions)
        } catch let error as FidoError {
            throw error
        }
    }
    
    func test_encodeInt(){
        let encodedInt = EncodingHelper.encodeInt(1)
        XCTAssert([1,0] == encodedInt)
    }
    
    class MockAssertionBuilder: ExtensionAssertionBuilder {
        
        override func biometricType() -> Int32 {
            return UserVerification.USER_VERIFY_PRESENCE.rawValue
        }
    }
    
}
