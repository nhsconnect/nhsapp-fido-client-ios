import XCTest
@testable import FidoClient

@available(iOS 10.0, *)
class FidoClientTests: XCTestCase {
    
    var fidoClient: FidoClient?
    
    override func setUp() {
        super.setUp()
        fidoClient = FidoClient()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_validateUAFRequest_ItsCorrectlyAdded() {
        let jsonString = "{\"header\": {\"upv\": {\"minor\":1, \"major\": 1}, \"op\":\"Auth\", \"appID\": \"anAppId\"}, \"challenge\": \"aChallenge\", \"username\": \"aUsername\"}"
        let regRequestJSON = JSON(parseJSON: jsonString)
        
        if let regRequest = try? FidoRequest(with: regRequestJSON) {
            let appID = "anAppId"
            regRequest.header.appID = appID
            let facetId: String = "anAppId"
            regRequest.header.appID = fidoClient!.selectFacetIdWhenAppIDisEmpty(request: regRequest, facetId: facetId)
            XCTAssert(regRequest.header.appID == appID)
        }else{
            assertionFailure("Failed to create FidoRequest")
            return
        }
        
    }
    
    func test_validateUAFRequest_IsNotEmpty() {
        let jsonString = "{\"header\": {\"upv\": {\"minor\":1, \"major\": 1}, \"op\":\"Auth\", \"appID\": \"anAppId\"}, \"challenge\": \"aChallenge\", \"username\": \"aUsername\"}"
        let regRequestJSON = JSON(parseJSON: jsonString)
        
        if let regRequest = try? FidoRequest(with: regRequestJSON) {
            let facetId: String = "anAppId"
            regRequest.header.appID = fidoClient!.selectFacetIdWhenAppIDisEmpty(request: regRequest, facetId: facetId)
            XCTAssert(regRequest.header.appID == facetId)
        }else{
            assertionFailure("Failed to create FidoRequest")
            return
        }
        
    }
    
    func test_validateUAFRequest_IsEmpty() {
        let jsonString = "{\"header\": {\"upv\": {\"minor\":1, \"major\": 1}, \"op\":\"Auth\", \"appID\": \"\"}, \"challenge\": \"aChallenge\", \"username\": \"aUsername\"}"
        let regRequestJSON = JSON(parseJSON: jsonString)
        
        if let regRequest = try? FidoRequest(with: regRequestJSON) {
            let facetId: String = "anAppId"
            regRequest.header.appID = fidoClient!.selectFacetIdWhenAppIDisEmpty(request: regRequest, facetId: facetId)
            XCTAssert(regRequest.header.appID == facetId)
        }else{
            assertionFailure("Failed to create FidoRequest")
            return
        }
        
    }
    
    func test_getFaceId() {
        var facetId: String = ""
        do {
            try facetId = fidoClient!.getFacetID()
        } catch {
            assertionFailure("Failed to create FidoRequest")
            return
        }
        XCTAssert(facetId == "ios:bundle-id:com.apple.dt.xctest.tool")
    }
}
