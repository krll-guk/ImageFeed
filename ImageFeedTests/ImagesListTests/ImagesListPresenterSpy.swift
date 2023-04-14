@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var loadNextPageCalled: Bool = false
    var view: ImageFeed.ImagesListViewControllerProtocol?
    
    var photos: [ImageFeed.Photo] = []
    
    func updateTableViewAnimated() {
        
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func numberOfRowsInSection() -> Int {
        return photos.count
    }
    
    func loadPhotosNextPage(indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            loadNextPage()
        }
    }
    
    func configCell(for cell: ImageFeed.ImagesListCell, with indexPath: IndexPath) {
        
    }
    
    func setLike(_ cell: ImageFeed.ImagesListCell) {
        
    }
    
    func loadNextPage() {
        loadNextPageCalled = true
    }
}
