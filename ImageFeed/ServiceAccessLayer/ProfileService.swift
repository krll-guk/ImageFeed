import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    init(username: String, name: String, loginName: String, bio: String) {
        self.username = username
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }
    
    init(fromResult: ProfileResult) {
        self.username = fromResult.username ?? ""
        self.name = "\(fromResult.firstName ?? "") \(fromResult.lastName ?? "")"
        self.loginName = "@\(fromResult.username ?? "")"
        self.bio = fromResult.bio ?? ""
    }
    
    static var test: Profile {
        return Profile(username: "test_username",
                       name: "test_name",
                       loginName: "test_loginName",
                       bio: "test_bio")
    }
}

struct ProfileResult: Codable {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
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
                let profile = Profile(fromResult: profileResult)
                self.profile = profile
                completion(.success(profile))
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
