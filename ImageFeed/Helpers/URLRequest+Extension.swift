import Foundation

enum requestType {
    case authToken(code: String)
    case profile
    case profileImage(username: String)
    case photos(nextPage: Int)
}

enum HTTPMethod: String {
    case GET, POST, DELETE, PUT
}

extension URLRequest {
    static func setupHTTPRequest(
        httpMethod: String = HTTPMethod.GET.rawValue,
        host: String = "api.unsplash.com",
        path: String,
        queryItems: [URLQueryItem] = []
    ) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
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
                host: "unsplash.com",
                path: "/oauth/token",
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
        case .photos(let nextPage):
            request = URLRequest.setupHTTPRequest(
                path: "/photos",
                queryItems: [.init(name: "page", value: "\(nextPage)")]
            )
        }
        
        if let token = OAuth2TokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
