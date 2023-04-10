import Foundation

fileprivate struct UserResult: Codable {
    let profileImage: ProfileImageURL
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

fileprivate struct ProfileImageURL: Codable {
    let medium: String
}

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    
    private(set) var avatarURL: String?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = URLRequest.makeRequest(.profileImage(username: username))
        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.medium
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL" : avatarURL]
                )
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
