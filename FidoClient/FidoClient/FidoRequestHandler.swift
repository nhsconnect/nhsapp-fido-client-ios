import Foundation
import os.log
import SwiftyJSON

@available(iOS 10.0, *)
class FidoRequestHandler {
    let keyManager: FidoKeyManager = FidoKeyManager()

    func getAuthenticationResponse(BiometricsAssertionScheme: String, privateKeyLabel:String, with authenticationRequest: FidoRequest, aaid: String) throws -> FidoResponse {
        var authenticationResponse = FidoResponse()
        var privateKey: SecKey
        do {
            try privateKey = keyManager.getPrivateKey(privateKeyLabel: privateKeyLabel)
            let builder: AuthenticationAssertionBuilder = AuthenticationAssertionBuilder(privateKey: privateKey)
            try authenticationResponse = processRequest(BiometricsAssertionScheme: BiometricsAssertionScheme,request: authenticationRequest, builder: builder, aaid: aaid)
            
            return authenticationResponse
        } catch let error as FidoError {
            throw error
        }
    }
    
    func getAuthRequest(authenticationUrl: String) throws -> JSON {
        do {
            return try FidoURLSessionManager.doRequest(with: generateAuthenticationRequest(authenticationUrl: authenticationUrl))
        } catch FidoError.networkRequestError {
            throw FidoError.networkRequestError
        } catch FidoError.parsingError {
            throw FidoError.parsingError
        } catch {
            throw FidoError.genericError
        }
    }
    
    func getRegistrationResponse(aaid: String, BiometricsAssertionScheme: String, privateKeyLabel:String, with registrationRequest: RegistrationRequest) throws -> FidoResponse {
        var registrationResponse = FidoResponse()
        var keyPair: KeyPair
        do {
            try keyPair = keyManager.generateKeyPair(privateKeyLabel:privateKeyLabel)
            let registrationAssertionBuilder: RegistrationAssertionBuilder = RegistrationAssertionBuilder(keyPair: keyPair)
            try registrationResponse = processRequest(BiometricsAssertionScheme: BiometricsAssertionScheme, request: registrationRequest, builder: registrationAssertionBuilder, aaid: aaid)
            return registrationResponse
        } catch let error as FidoError{
            throw error
        }
    }
    
    func getRegistrationRequestWith(registrationUrl: String, accessToken: String) throws -> JSON {
        do {
            let request: URLRequest = try generateRegistrationRequest(registrationUrl: registrationUrl,accessToken: accessToken)
            let response = try FidoURLSessionManager.doRequest(with: request)
            
            return response
        } catch FidoError.parsingError {
            throw FidoError.parsingError
        }
    }
    
    func generateAuthenticationRequest(authenticationUrl: String) throws -> URLRequest {
        let authenticationUrl: String = authenticationUrl//endpointHelper.authenticationRequestEndpoint
        do {
            let request = try generateRequest(authenticationUrl)
            return request
        } catch FidoError.parsingError {
            throw FidoError.parsingError
        }
    }
    
    func generateRegistrationRequest(registrationUrl: String, accessToken: String) throws -> URLRequest {
        //let registrationUrl: String = endpointHelper.requestRequestEndpoint
        do {
            var request = try generateRequest(registrationUrl)
            request.setValue(accessToken, forHTTPHeaderField: "Authorization")
            return request
        } catch FidoError.parsingError {
            throw FidoError.parsingError
        }
    }
    
    func generateRequest(_ url: String) throws -> URLRequest {
        if var components = URLComponents(string: url) {
            let parameters: URLQueryItem = URLQueryItem(name: "http.protocol.handle-redirects", value: "false")
            components.queryItems?.append(parameters)
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            var request = URLRequest(url: components.url!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData)
            request.httpMethod = "GET"
            
            return request
        }
        throw FidoError.parsingError
    }
    
    func generateDeRegisterRequest(aaid: String, privateKeyLabel: String, keyId: String, facetId: String) -> DeregistrationRequest {
        keyManager.deletePrivateKey(privateKeyLabel: privateKeyLabel)
        let upv = Version(major: 1, minor: 0)
        let header = OperationHeader(upv,
                                     Operation.Dereg,
                                     facetId)
        
        let deregisterAuthenticator = DeregisterAuthenticator(aaid: aaid, keyID: keyId)
        let deregistrationRequest = DeregistrationRequest(header: header, authenticators: [deregisterAuthenticator])
        
        return deregistrationRequest
    }
    
    func clientSendRegistrationResponse(_ uafMessage: String, registrationResponseEndpoint: String) throws -> JSON {
        do {
            return try sendResponse(uafMessage: uafMessage, endpoint: registrationResponseEndpoint, authToken: nil)
        } catch let error as FidoError {
            throw error
        }
    }
    
    func clientSendDeRegistrationRequest(_ uafMessage: String, deregistrationRequestEndpoint: String, authToken: String) throws {
        do {
            let fidoResponse = try sendResponse(uafMessage: uafMessage, endpoint: deregistrationRequestEndpoint, authToken: authToken)
            NSLog("Deregistration response: \(fidoResponse)")
        } catch FidoError.parsingError {
            throw FidoError.parsingError
        }
    }
    
    private func sendResponse(uafMessage: String, endpoint: String, authToken: String?) throws -> JSON {
        do {
            var request: URLRequest = try generateRequest(uafMessage: uafMessage, endpoint: endpoint)
            if authToken != nil {
                request.setValue(authToken, forHTTPHeaderField: "Authorization")
            }
            
            return try FidoURLSessionManager.doRequest(with: request)
        } catch FidoError.parsingError {
            throw FidoError.parsingError
        }
    }
    
    private func generateRequest(uafMessage: String, endpoint: String) throws -> URLRequest {
        if let url = URL(string: endpoint) {
            var request: URLRequest = URLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            if let data = uafMessage.data(using: (.utf8)){
                request.httpBody = data
            }
            
            return request
        }
        throw FidoError.parsingError
    }
    
    func processRequest(BiometricsAssertionScheme: String, request: FidoRequest, builder: FidoAssertionBuilder, aaid: String) throws -> FidoResponse {
        var response = FidoResponse()
        
        do {
            try response.header = OperationHeader(request: request)
            var finalChallengeParams = FinalChallengeParams()
            finalChallengeParams.appID = request.header.appID
            UserDefaultsManager.setAppID(finalChallengeParams.appID)
            finalChallengeParams.facetID = ""
            finalChallengeParams.challenge = request.challenge
            try response.assertions = setAssertions(BiometricsAssertionScheme: BiometricsAssertionScheme, response: response, builder: builder, aaid: aaid)
            let base64Params = try JSONEncoder().encode(finalChallengeParams).base64EncodedDataRFC4648()
            response.fcParams = base64Params
        } catch let error as FidoError {
            throw error
        }
        
        return response
    }

    private func setAssertions(BiometricsAssertionScheme: String, response: FidoResponse, builder: FidoAssertionBuilder, aaid: String) throws -> [Assertion] {
        var assertion = Assertion()
        assertion.assertionScheme = BiometricsAssertionScheme//config().BiometricsAssertionScheme
        do {
            try assertion.assertion = builder.getAssertions(response: response, aaid: aaid)
        } catch let error as FidoError {
            throw error
        }
        
        return [assertion]
    }
}
