import Foundation
import Kingfisher

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func updateProfileDetails(profile: Profile)
    func viewDidLoad()
    func updateAvatar()
    func profileLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        
        updateAvatar()
    }
    
    func updateProfileDetails(profile: Profile) {
        view?.nameLabel.text = profile.name
        view?.loginNameLabel.text = profile.loginName
        view?.descriptionLabel.text = profile.bio
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        
        view?.profileImageView.kf.indicatorType = .activity
        view?.profileImageView.kf.setImage(with: url, placeholder: view?.placeholder)
    }
    
    func profileLogout() {
        OAuth2TokenStorage.token = nil
        WebViewViewController.clean()
        view?.window.rootViewController = SplashViewController()
    }
}
