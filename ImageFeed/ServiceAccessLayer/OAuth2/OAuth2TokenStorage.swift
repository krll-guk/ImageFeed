import Foundation

final class OAuth2TokenStorage {
    private static let tokenKey: String = "tokenKey"
    
    static var token: String? {
        get {
            UserDefaults.standard.string(forKey: Self.tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.tokenKey)
        }
    }
}
