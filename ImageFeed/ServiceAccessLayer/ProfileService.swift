import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}

fileprivate struct ProfileResult: Codable {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}

final class ProfileService {
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = URLRequest.makeRequest(.profile)
        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username ?? "username",
                    name: "\(profileResult.firstName ?? "Ivan") \(profileResult.lastName ?? "Ivanov")",
                    loginName: "@\(profileResult.username ?? "username")",
                    bio: profileResult.bio ?? ""
                )
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
