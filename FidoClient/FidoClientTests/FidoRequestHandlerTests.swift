import XCTest
@testable import FidoClient

@available(iOS 10.0, *)
class FidoRequestHandlerTests: XCTestCase {
    
    var fidoRequestHandler: FidoRequestHandler?

    override func setUp() {
        super.setUp()

        fidoRequestHandler = FidoRequestHandler()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_generateDeregistrationRequest(){
        let deregRequest = fidoRequestHandler!.generateDeRegisterRequest(aaid: "AAID", privateKeyLabel: "privateKeyLabel", keyId: "keyID", facetId: "facetID")
        print(deregRequest)
        XCTAssert(deregRequest.header.appID == "facetID")
        XCTAssert(deregRequest.authenticators[0].keyID == "keyID")
        XCTAssert(deregRequest.authenticators[0].aaid == "AAID")

    }
    
    func test_generateRegistrationRequest() {
        do {
            var registrationRequest: URLRequest
            try registrationRequest = fidoRequestHandler!.generateRegistrationRequest(registrationUrl: "www.test.com", accessToken: "token")
            XCTAssert(registrationRequest.url?.absoluteString == "www.test.com")
            XCTAssert(registrationRequest.value(forHTTPHeaderField: "Authorization") == "token")
        } catch {
            assertionFailure("Failed to register")
            return
        }
    }
    
    func test_generateAuthenticationRequest() {
        do {
            var registrationRequest: URLRequest
            try registrationRequest = fidoRequestHandler!.generateAuthenticationRequest(authenticationUrl: "www.test.com")
            XCTAssert(registrationRequest.url?.absoluteString == "www.test.com")
        } catch {
            assertionFailure("Failed to generate request")
            return
        }
    }
    
    func test_processRequest() {

        var fidoAssertionBuilder: FidoAssertionBuilderStub
        var fidoResponse: FidoResponse
        let jsonString = "{\"header\": {\"upv\": {\"minor\":1, \"major\": 1}, \"op\":\"Auth\", \"appID\": \"anAppId\"}, \"challenge\": \"aChallenge\", \"username\": \"aUsername\"}"
        let regRequestJSON = JSON(parseJSON: jsonString)
        
        if let regRequest = try? FidoRequest(with: regRequestJSON) {
        do {
            fidoAssertionBuilder = FidoAssertionBuilderStub()
            try fidoResponse = fidoRequestHandler!.processRequest(BiometricsAssertionScheme: "scheme", request: regRequest, builder: fidoAssertionBuilder, aaid: "AAID")
            print(fidoResponse)
            XCTAssert(fidoResponse.header?.appID == "anAppId")
            XCTAssert(fidoResponse.assertions?[0].assertion == "assertion")
            XCTAssert(fidoResponse.assertions?[0].assertionScheme == "scheme")
        } catch {
            assertionFailure("Failed to process request")
            return
        }
        } else {
            assertionFailure("Failed to parse json")
            return
        }
        
    }

}

class FidoAssertionBuilderStub: FidoAssertionBuilder {
    override func getAssertions(response: FidoResponse, aaid: String) throws -> String {
        return "assertion"
    }
}
