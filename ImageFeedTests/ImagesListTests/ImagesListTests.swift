@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testLoadPhotosNextPage() {
        //given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        let photo = Photo.test
        presenter.photos = [photo, photo]
        let indexPath = IndexPath(row: 1, section: 0)
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        viewController.tableView(UITableView(), willDisplay: UITableViewCell(), forRowAt: indexPath)
        
        //then
        XCTAssertTrue(presenter.loadNextPageCalled)
    }
    
    func testPhotoURL() {
        //given
        let presenter = ImagesListPresenter()
        let photo = Photo.test

        //when
        let url = presenter.getPhotoURL(photo: photo)
        let urlString = url.absoluteString
        
        //then
        XCTAssertTrue(urlString.contains("test"))
    }
}
