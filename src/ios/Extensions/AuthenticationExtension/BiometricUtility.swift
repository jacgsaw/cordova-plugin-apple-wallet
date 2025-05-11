import Foundation
import LocalAuthentication

class BiometricUtility {
    static let shared = BiometricUtility()

    private init() {}

    func checkBiometricAuthorization(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to continue.") { success, evaluateError in
                DispatchQueue.main.async {
                    if success {
                        completion(true, "Authentication successful.")
                    } else {
                        if let error = evaluateError as NSError? {
                            switch error.code {
                            case LAError.authenticationFailed.rawValue:
                                completion(false, "Authentication failed.")
                            case LAError.userCancel.rawValue:
                                completion(false, "User canceled authentication.")
                            case LAError.userFallback.rawValue:
                                completion(false, "User chose to use password.")
                            case LAError.biometryNotAvailable.rawValue:
                                completion(false, "Biometry is not available.")
                            case LAError.biometryNotEnrolled.rawValue:
                                completion(false, "No biometric method is set up.")
                            case LAError.biometryLockout.rawValue:
                                completion(false, "Biometry is locked out.")
                            default:
                                completion(false, "Unknown error: \(error.localizedDescription)")
                            }
                        } else {
                            completion(false, "Unknown error.")
                        }
                    }
                }
            }
        } else {
            completion(false, error?.localizedDescription)
        }
    }
}