import Foundation
import os.log

@available(iOS 10.0, *)
class FidoEncodingHandler {
    let requestHandler = FidoRequestHandler()

    @available(iOS 10.0, *)
    func getEncodedRegistrationResponse(aaid: String, BiometricsAssertionScheme: String, privateKeyLabel: String, with registrationRequest: RegistrationRequest, keyIDPrefix: String) throws -> String {
        let response: FidoResponse
        do {
            try response = requestHandler.getRegistrationResponse(aaid: aaid, BiometricsAssertionScheme: BiometricsAssertionScheme, privateKeyLabel: privateKeyLabel, with: registrationRequest, keyIDPrefix: keyIDPrefix)
            let encodedResponse = try encodeResponse(response)
            return encodedResponse
        } catch let error as FidoError {
            throw error
        }
    }
    
    private func encodeResponse(_ response: FidoResponse) throws -> String {
        let response: [FidoResponse] = [response]
        do {
            let jsonResponse = try JSONEncoder().encode(response)
            if let responseString = String(data: jsonResponse, encoding: .utf8){
                return responseString
            }
        } catch {
            os_log("Error encoding JSON", log: OSLog.default, type: .error)
        }
        throw FidoError.parsingError
    }
    
    func encodeDeregistrationRequest(_ request: DeregistrationRequest) throws -> String {
        let request: [DeregistrationRequest] = [request]
        if let jsonRequest = try? JSONEncoder().encode(request) {
            if let requestString = String(data: jsonRequest, encoding: .utf8) {
                return requestString
            }
        }
        os_log("Failed to encode deregistration request", log: OSLog.default, type: .error)
        
        throw FidoError.parsingError
    }
}
