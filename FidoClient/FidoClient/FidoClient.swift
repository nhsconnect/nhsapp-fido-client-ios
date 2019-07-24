import Foundation
import os.log

public protocol FidoClientProtocol {
    func startRegistration(aaid: String, BiometricsAssertionScheme: String, accessToken: String, registrationUrl: String, privateKeyLabel: String) throws -> String
    func completeRegistration(_ encodedResponse: String, registrationResponseEndpoint: String) throws -> Bool
    func startAuthorisation(aaid: String, BiometricsAssertionScheme: String, privateKeyLabel: String,authenticationUrl: String) throws -> String
    func completeAuthorisation(aaid: String, BiometricsAssertionScheme: String, privateKeyLabel:String, authenticationUrl: String, completion: @escaping (_: FidoResponse ) throws -> ()) throws
    func doDeregistration(aaid: String, privateKeyLabel: String, deregistrationRequestEndpoint: String) throws
    func getBiometricAvailability() throws -> BiometricState
}

@available(iOS 10.0, *)
public class FidoClient: FidoClientProtocol {
    let encodingHandler = FidoEncodingHandler()
    private let requestHandler: FidoRequestHandler
    let bundleID = "ios:bundle-id:"
    
    init(requestHandler: FidoRequestHandler = FidoRequestHandler()) {
        self.requestHandler = requestHandler
    }
    
    public func register(aaid: String, BiometricsAssertionScheme: String, accessToken: String, registrationUrl: String, privateKeyLabel: String, registrationResponseEndpoint: String) throws -> Bool {
        do {
            let registrationResponse = try startRegistration(aaid: aaid, BiometricsAssertionScheme: BiometricsAssertionScheme, accessToken: accessToken, registrationUrl: registrationUrl, privateKeyLabel: privateKeyLabel)
            
            return try completeRegistration(registrationResponse, registrationResponseEndpoint: registrationResponseEndpoint)
        } catch let error as FidoError {
            throw error
        }
    }
 
    public func completeAuthorisationRequestAndRetrieveBase64Response(aaid: String, BiometricsAssertionScheme: String, privateKeyLabel:String, authenticationUrl: String) throws -> String {
        do {
            let base64Response = try startAuthorisation(aaid: aaid, BiometricsAssertionScheme: BiometricsAssertionScheme, privateKeyLabel: privateKeyLabel, authenticationUrl: authenticationUrl)
            return base64Response
        } catch let error as FidoError {
            throw error
        }
    }
    
    public func startRegistration(aaid: String, BiometricsAssertionScheme: String, accessToken: String, registrationUrl: String, privateKeyLabel: String) throws -> String {
        do {
            let registrationRequestData = try requestHandler.getRegistrationRequestWith(registrationUrl: registrationUrl, accessToken: accessToken)
            let request: RegistrationRequest = try RegistrationRequest(with: registrationRequestData[0])
            request.header.appID = try self.selectFacetIdWhenAppIDisEmpty(request: request, facetId: getFacetID())
            let encodedResponse = try encodingHandler.getEncodedRegistrationResponse(aaid: aaid, BiometricsAssertionScheme: BiometricsAssertionScheme, privateKeyLabel: privateKeyLabel, with: request)
            if !encodedResponse.isEmpty {
                return encodedResponse
            }
        throw FidoError.genericError
        } catch let error as FidoError {
            throw error
        }
    }
    
    public func completeRegistration(_ encodedResponse: String, registrationResponseEndpoint: String) throws -> Bool {
        do {
            let fidoResponse = try requestHandler.clientSendRegistrationResponse(encodedResponse, registrationResponseEndpoint: registrationResponseEndpoint)
            if fidoResponse[0]["status"].string != nil && fidoResponse[0]["status"].string == "SUCCESS" {
                os_log("Registration Successful", log: OSLog.default, type: OSLogType.info)
                
                return true
            }
        } catch let error as FidoError {
            throw error
        }
        return false
    }
    
    public func startAuthorisation(aaid: String, BiometricsAssertionScheme: String, privateKeyLabel:String, authenticationUrl: String) throws -> String {
        do {
            var base64Response = String()
            let semaphore = DispatchSemaphore(value: 0)
            try completeAuthorisation(aaid: aaid, BiometricsAssertionScheme: BiometricsAssertionScheme, privateKeyLabel: privateKeyLabel, authenticationUrl:authenticationUrl, completion: { authenticationResponse in
                let response: [FidoResponse] = [authenticationResponse]
                let jsonResponse = try JSONEncoder().encode(response)
                if let message = String(data: jsonResponse, encoding: .utf8) {
                    if let authenticationResponseB64 = message.data(using: .utf8)?.base64EncodedDataRFC4648() {
                       base64Response = authenticationResponseB64
                    }
                }
                semaphore.signal()
            })
            semaphore.wait()
            
            return base64Response
        } catch let error as FidoError {
            throw error
        }
    }
    
    public func completeAuthorisation(aaid: String, BiometricsAssertionScheme: String, privateKeyLabel:String, authenticationUrl: String, completion: @escaping (_: FidoResponse ) throws -> ()) throws {
        do {
            let response = try requestHandler.getAuthRequest(authenticationUrl: authenticationUrl)
            var authResponse: FidoResponse
            let request: FidoRequest = try FidoRequest(with: response[0])
            request.header.appID = try selectFacetIdWhenAppIDisEmpty(request: request, facetId: getFacetID())
            authResponse = try requestHandler.getAuthenticationResponse(BiometricsAssertionScheme: BiometricsAssertionScheme, privateKeyLabel: privateKeyLabel, with: request, aaid: aaid)
            try completion(authResponse)
        } catch let error as FidoError {
            throw error
        }
    }
    
    public func doDeregistration(aaid: String, privateKeyLabel: String, deregistrationRequestEndpoint: String) throws {
        do {
            let keyId = try UserDefaultsManager.getKeyID()
            UserDefaultsManager.deleteKeyID()
            UserDefaultsManager.setBiometricState(nil)
            let deregistrationRequest = try requestHandler.generateDeRegisterRequest(aaid: aaid, privateKeyLabel: privateKeyLabel, keyId: keyId, facetId: getFacetID())
            let encodedRequest = try encodingHandler.encodeDeregistrationRequest(deregistrationRequest)
            if !encodedRequest.isEmpty{
                try requestHandler.clientSendDeRegistrationRequest(encodedRequest, deregistrationRequestEndpoint: deregistrationRequestEndpoint)
            }
        } catch let error as FidoError {
            throw error
        }
    }
    
    func selectFacetIdWhenAppIDisEmpty(request: FidoRequest, facetId: String) -> String {
        if (request.header.appID.isEmpty) {
            return facetId
        }
        return request.header.appID
    }
    
    func getFacetID() throws -> String {
        if let facetID = Bundle.main.bundleIdentifier {
            return bundleID + facetID
        }
        throw FidoError.genericError
    }
    
    public func getBiometricAvailability() throws -> BiometricState {
        return UserDefaultsManager.getBiometricAvailability()
    }
}

