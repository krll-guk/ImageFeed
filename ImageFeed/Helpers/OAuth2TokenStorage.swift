import Foundation
import SwiftKeychainWrapper

fileprivate let storage = KeychainWrapper.standard

final class OAuth2TokenStorage {
    static var token: String? {
        get {
            storage.string(forKey: Constants.authTokenKey)
        }
        set {
            if let token = newValue {
                storage.set(token, forKey: Constants.authTokenKey)
            } else {
                storage.removeObject(forKey: Constants.authTokenKey)
            }
        }
    }
}
