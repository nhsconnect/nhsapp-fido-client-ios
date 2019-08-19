public enum FidoError: Error {
    case invalidBiometrics
    case genericError
    case parsingError
    case encryptionError
    case networkRequestError
    case keyRetrievalError
    case accessTokenError
}
