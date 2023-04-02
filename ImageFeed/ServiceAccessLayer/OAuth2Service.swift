import Foundation

fileprivate struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = URLRequest.makeRequest(.authToken(code: code))
        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                OAuth2TokenStorage.token = body.accessToken
                completion(.success(body.accessToken))
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
}
