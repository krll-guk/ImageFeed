import UIKit

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let oauth2Service = OAuth2Service.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if OAuth2TokenStorage.token != nil {
            UIBlockingProgressHUD.show()
            fetchProfile()
        } else {
            showAuthViewController()
        }
    }
    
    private func showAuthViewController() {
        guard let authViewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func setupUI() {
        let splashScreenLogo = UIImageView()
        splashScreenLogo.image = UIImage(named: "Vector")
        splashScreenLogo.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor(named: "YP Black")
        view.addSubview(splashScreenLogo)
        
        NSLayoutConstraint.activate([
            splashScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            return assertionFailure("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        fetchOAuthToken(code)
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchProfile()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showTokenError()
            }
        }
    }
    
    private func fetchProfile() {
        profileService.fetchProfile() { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let profile):
                self.profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure:
                self.showProfileError()
            }
        }
    }
}

extension SplashViewController {
    private func showProfileError() {
        AlertPresenter.showAlert(
            vc: self,
            title: "Что-то пошло не так(",
            message: "Не удалось загрузить данные",
            firstButtonText: "Ок", { [weak self] in
                guard let self = self else { return }
                UIBlockingProgressHUD.show()
                self.fetchProfile()
            }
        )
    }
    
    private func showTokenError() {
        AlertPresenter.showAlert(
            vc: presentedViewController ?? self,
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            firstButtonText: "Ок"
        )
    }
}
