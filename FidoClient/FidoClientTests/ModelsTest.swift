import XCTest
@testable import FidoClient

class ModelTests: XCTestCase {
    
    func test_operationHeaderValidJSON(){
        let jsonString: String = "{\"upv\": {\"minor\":1, \"major\": 1}, \"op\":\"Auth\", \"appID\": \"anAppId\"}"
        let operationHeaderJson = JSON(parseJSON: jsonString)
        if let operationHeader = try? OperationHeader(with: operationHeaderJson) {
            XCTAssertNotNil(operationHeader)
            XCTAssert(operationHeader.appID == "anAppId")
            XCTAssert(operationHeader.op == Operation.Auth)
            XCTAssert(operationHeader.upv.major == 1)
            XCTAssert(operationHeader.upv.minor == 1)
        } else {
            assertionFailure("Failed to create operation header)")
            return
        }
    }
    
    func test_operationHeaderNoUPV(){
        let jsonString: String = "{\"op\":\"Auth\", \"appID\": \"anAppId\"}"
        let operationHeaderJson = JSON(parseJSON: jsonString)
        XCTAssertThrowsError(try OperationHeader(with: operationHeaderJson)) { error in
            XCTAssertEqual(error as? FidoError, FidoError.parsingError)
        }
    }
    
    func test_operationHeaderInvalidUPV(){
        let jsonString: String = "{\"upv\": {\"NOTVALID\":1, \"major\": 1}, \"op\":\"Auth\", \"appID\": \"anAppId\"}"
        let operationHeaderJson = JSON(parseJSON: jsonString)
        XCTAssertThrowsError(try OperationHeader(with: operationHeaderJson)) { error in
            XCTAssertEqual(error as? FidoError, FidoError.parsingError)
        }
    }
    
    func test_operationHeaderNoOP(){
        let jsonString: String = "{\"upv\": {\"minor\":1, \"major\": 1}, \"appID\": \"anAppId\"}"
        let operationHeaderJson = JSON(parseJSON: jsonString)
        XCTAssertThrowsError(try OperationHeader(with: operationHeaderJson)) { error in
            XCTAssertEqual(error as? FidoError, FidoError.parsingError)
        }
    }
    
    func test_operationHeaderInvalidOP(){
        let jsonString: String = "{\"upv\": {\"minor\":1, \"major\": 1}, \"op\":\"INVALID\", \"appID\": \"anAppId\"}"
        let operationHeaderJson = JSON(parseJSON: jsonString)
        XCTAssertThrowsError(try OperationHeader(with: operationHeaderJson)) { error in
            XCTAssertEqual(error as? FidoError, FidoError.parsingError)
        }
    }
    
    func test_operationHeaderNoAppId(){
        let jsonString: String = "{\"upv\": {\"minor\":1, \"major\": 1}, \"op\":\"Auth\"}"
        let operationHeaderJson = JSON(parseJSON: jsonString)
        XCTAssertThrowsError(try OperationHeader(with: operationHeaderJson)) { error in
            XCTAssertEqual(error as? FidoError, FidoError.parsingError)
        }
    }
    
    func test_fidoRequestValidJSON(){
        let jsonString = "{\"header\": {\"upv\": {\"minor\":1, \"major\": 1}, \"op\":\"Auth\", \"appID\": \"anAppId\"}, \"challenge\": \"aChallenge\", \"username\": \"aUsername\"}"
        let regRequestJSON = JSON(parseJSON: jsonString)
        
        if let regRequest = try? RegistrationRequest(with: regRequestJSON) {
            XCTAssertNotNil(regRequest)
            XCTAssert(regRequest.header.op == Operation.Auth)
            XCTAssert(regRequest.challenge == "aChallenge")
            XCTAssert(regRequest.username == "aUsername")
        } else {
            assertionFailure("Failed to create Fido Request)")
            return
        }
    }
    
    func test_fidoRequestNoHeader(){
        let jsonString = "{\"challenge\": \"aChallenge\", \"username\": \"aUsername\"}"
        let regRequestJSON = JSON(parseJSON: jsonString)
        
        XCTAssertThrowsError(try FidoRequest(with: regRequestJSON) ) { error in
            XCTAssertEqual(error as? FidoError, FidoError.parsingError)
        }
    }
    func test_fidoRequestNoChallenge(){
        let jsonString = "{\"NOHEADER\": {\"upv\": {\"minor\":1, \"major\": 1}, \"op\":\"Auth\", \"appID\": \"anAppId\"}, \"username\": \"aUsername\"}"
        let regRequestJSON = JSON(parseJSON: jsonString)
        
        XCTAssertThrowsError(try FidoRequest(with: regRequestJSON) ) { error in
            XCTAssertEqual(error as? FidoError, FidoError.parsingError)
        }
    }
    func test_fidoRequestNoUsername(){
        let jsonString = "{\"header\": {\"upv\": {\"minor\":1, \"major\": 1}, \"op\":\"Auth\", \"appID\": \"anAppId\"}, \"challenge\": \"aChallenge\"}"
        let regRequestJSON = JSON(parseJSON: jsonString)
        
        XCTAssertThrowsError(try RegistrationRequest(with: regRequestJSON) ) { error in
            XCTAssertEqual(error as? FidoError, FidoError.parsingError)
        }
    }
}
