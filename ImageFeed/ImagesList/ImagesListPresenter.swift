import Foundation
import Kingfisher

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    func updateTableViewAnimated()
    func viewDidLoad()
    func numberOfRowsInSection() -> Int
    func loadPhotosNextPage(indexPath: IndexPath)
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func setLike(_ cell: ImagesListCell)
    func loadNextPage()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    
    var photos: [Photo] = []
    
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
        
        loadNextPage()
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                view?.tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func numberOfRowsInSection() -> Int {
        return photos.count
    }
    
    func loadPhotosNextPage(indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            loadNextPage()
        }
    }
    
    func loadNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func getPhotoURL(photo: Photo) -> URL {
        return URL(string: photo.thumbImageURL)!
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let url = getPhotoURL(photo: photo)
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: url,
            placeholder: view?.placeholder
        ) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.view?.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                self.view?.showLoadError()
                print(error)
            }
        }
        
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        let likeImage = photo.isLiked ? view?.likeButtonOn : view?.likeButtonOff
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
    func setLike(_ cell: ImagesListCell) {
        guard let indexPath = view?.tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLiked: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let isLiked):
                self.photos = self.imagesListService.photos
                cell.setIsLiked(isLiked)
            case .failure:
                self.view?.showLikeError()
            }
        }
    }
}
