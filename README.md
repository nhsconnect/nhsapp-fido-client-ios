# FIDO UAF (Universal Authentication Framework) client for iOS

The FIDO UAF client is a CocoaPod to authenticate logging in to iOS apps without a password.

You can use the client to:

* register and deregister biometric details for Touch ID and Face ID
* authorise against registered biometric details

We'll add the client to the public [CocoaPods dependency manager](https://github.com/CocoaPods/CocoaPods) soon.

## Requirements

* iOS 10.0 or above
* Familiarity with [CocoaPods](https://cocoapods.org/)

## Installation

1. Get the [LoginKit](https://cocoapods.org/pods/LoginKit) library from CocoaPods.

2. Install LoginKit by adding this line to your Podfile:

    ```ruby
    pod 'FidoClientIOS'
    ```

## Getting started

All calls go through the `FidoClient` class. Instantiate it, then register the client:

```swift
try FidoClient().register(aaid: aaid, BiometricsAssertionScheme: BiometricsAssertionScheme, accessToken: accessToken, registrationUrl: registrationUrl, privateKeyLabel: privateKeyLabel, registrationResponseEndpoint: registrationResponseEndpoint)
```

When the user has registered, they can log in to your application using any of the biometric identifiers linked to their device.

To log in, call the authentication endpoint:

```swift
try FidoClient().completeAuthorisationRequestAndRetrieveBase64Response(aaid: aaid, BiometricsAssertionScheme: BiometricsAssertionScheme, privateKeyLabel: privateKeyLabel, authenticationUrl: authenticationUrl)
```

From this point, they're logged in and you can redirect using the base64 response.

If the user no longer wants to use biometrics to log in, you can deregister them:

```swift
UserDefaultsManager.setBiometricState(nil)
try FidoClient().doDeregistration(aaid: aaid, privateKeyLabel: privateKeyLabel, deregistrationRequestEndpoint: deregistrationRequestEndpoint)
```

### Error handling

`FidoClient` throws the following errors:

```swift
case invalidBiometrics
case genericError
case parsingError
case encryptionError
case networkRequestError
case keyRetrievalError
case accessTokenError
```

## Contribute

We appreciate contributions and there are several ways you can help. For more information, see our [contributing guidelines](/CONTRIBUTING.md).

## Get in touch

The FIDO UAF (Universal Authentication Framework) client for iOS is maintained by NHS Digital. [Email us](mailto:nhsapp@nhs.net) or open a [GitHub issue](https://github.com/nhsconnect/nhsapp-fido-client-ios/issues/new).

### Reporting vulnerabilities

If you believe you've found a vulnerability or security concern in the client, please report it to us:

1. Submit a vulnerability report through [HackerOne's form](https://hackerone.com/2e6793b1-d580-4172-9ba3-04c98cdfb478/embedded_submissions/new).

2. Put "FAO NHS Digital's NHS App team" in the first line of the description.

## License

The codebase is released under the MIT License, unless stated otherwise. This covers both the codebase and any sample code in the documentation.
