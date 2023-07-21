@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testLogout() {
        //given
        let presenter = ProfilePresenter()
        
        //when
        presenter.profileLogout()
        
        //then
        XCTAssertEqual(OAuth2TokenStorage.token, nil)
    }
    
    func testProfileDetails() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenter()
        let profile = Profile.test
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.updateProfileDetails(profile: profile)
        
        //then
        XCTAssertEqual(viewController.nameLabel.text, "test_name")
        XCTAssertEqual(viewController.loginNameLabel.text, "test_loginName")
        XCTAssertEqual(viewController.descriptionLabel.text, "test_bio")
    }
}
