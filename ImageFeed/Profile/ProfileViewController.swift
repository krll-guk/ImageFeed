import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private lazy var profileImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Photo")
        image.layer.cornerRadius = 35
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 23)
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = UIColor(named: "YP Gray")
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "Exit")!,
            target: self,
            action: #selector(Self.didTapExitButton)
        )
        button.tintColor = UIColor(named: "YP Red")
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
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
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "Stub"))
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YP Black")
        setupProfileImageView()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupExitButton()
    }
    
    @objc
    private func didTapExitButton() {
        nameLabel.isHidden = true
        loginNameLabel.isHidden = true
        descriptionLabel.isHidden = true
        profileImageView.image = UIImage(named: "Stub")
        OAuth2TokenStorage.token = nil
    }
}

extension ProfileViewController {
    private func setupProfileImageView() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupLoginNameLabel() {
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupExitButton() {
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            exitButton.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
}
