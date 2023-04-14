@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    
    func updateProfileDetails(profile: ImageFeed.Profile) {
        
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateAvatar() {
        
    }
    
    func profileLogout() {
        
    }
}
