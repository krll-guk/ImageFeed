import Foundation

enum requestType {
    case authToken(code: String)
    case profile
    case profileImage(username: String)
}

enum HTTPMethod: String {
    case GET, POST, DELETE, PUT
}

extension URLRequest {
    static func setupHTTPRequest(
        httpMethod: String = HTTPMethod.GET.rawValue,
        baseURL: String = Constants.apiURL,
        path: String,
        queryItems: [URLQueryItem] = []
    ) -> URLRequest {
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
    
    static func makeRequest(_ type: requestType) -> URLRequest {
        var request: URLRequest
        
        switch type {
        case .authToken(let code):
            request = URLRequest.setupHTTPRequest(
                httpMethod: HTTPMethod.POST.rawValue,
                baseURL: Constants.oauthURL,
                path: "/token",
                queryItems: [
                    .init(name: "client_id", value: Constants.accessKey),
                    .init(name: "client_secret", value: Constants.secretKey),
                    .init(name: "redirect_uri", value: Constants.redirectURI),
                    .init(name: "grant_type", value: "authorization_code"),
                    .init(name: "code", value: code)
                ]
            )
        case .profile:
            request = URLRequest.setupHTTPRequest(path: "/me")
        case .profileImage(let username):
            request = URLRequest.setupHTTPRequest(path: "/users/\(username)")
        }
        
        if let token = OAuth2TokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
