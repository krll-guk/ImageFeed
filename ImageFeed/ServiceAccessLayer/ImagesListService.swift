import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
    init(fromResult: PhotoResult) {
        self.id = fromResult.id
        self.size = .init(width: fromResult.width, height: fromResult.height)
        self.createdAt = ISO8601DateFormatter().date(from: fromResult.createdAt ?? "")
        self.welcomeDescription = fromResult.description
        self.thumbImageURL = fromResult.urls.thumb
        self.largeImageURL = fromResult.urls.full
        self.isLiked = fromResult.likedByUser
    }
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

struct UrlsResult: Codable {
    let full: String
    let thumb: String
    
    enum CodingKeys: String, CodingKey {
        case full, thumb
    }
}

struct LikeResult: Codable {
    let photo: PhotoResult
}

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        let request = URLRequest.makeRequest(.photos(nextPage: nextPage))
        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photoResult):
                let photos = photoResult.map {
                    return Photo(fromResult: $0)
                }
                self.photos += photos
                self.lastLoadedPage = nextPage
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["photos" : self.photos]
                )
            case .failure(let error):
                print(error)
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}

extension ImagesListService {
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = URLRequest.makeRequest(.like(id: photoId, isLiked: isLiked))
        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<LikeResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let likeResponse):
                if let index = self.photos.firstIndex(where: { $0.id == likeResponse.photo.id }) {
                    self.photos[index].isLiked = likeResponse.photo.likedByUser
                }
                completion(.success(likeResponse.photo.likedByUser))
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
