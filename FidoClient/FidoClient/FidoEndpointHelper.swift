import Foundation

struct FidoEndpointHelper {
    public let requestRequestEndpoint: String
    public let registrationResponseEndpoint: String
    public let authenticationRequestEndpoint: String
    public let deregistrationRequestEndpoint: String

    public init(FidoServerUrl: String,
         BiometricsRegistrationRequestEndpoint: String,
         BiometricsRegistrationResponseEndpoint: String,
         BiometricsAuthenticationRequestEndpoint: String,
         BiometricsDeregistrationRequestEndpoint: String) {
        
        self.requestRequestEndpoint = FidoServerUrl + BiometricsRegistrationRequestEndpoint
        self.registrationResponseEndpoint = FidoServerUrl + BiometricsRegistrationResponseEndpoint
        self.authenticationRequestEndpoint = FidoServerUrl + BiometricsAuthenticationRequestEndpoint
        self.deregistrationRequestEndpoint = FidoServerUrl + BiometricsDeregistrationRequestEndpoint

    }
}
