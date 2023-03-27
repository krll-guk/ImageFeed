import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Constants.authTokenKey)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: Constants.authTokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: Constants.authTokenKey)
            }
        }
    }
}
