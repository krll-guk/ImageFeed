import UIKit

final class ProfileViewController: UIViewController {
    
    private var profileImageView: UIImageView!
    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addProfileImage()
        addExitButton()
        addNameLabel()
        addLoginNameLabel()
        addDescriptionLabel()
    }
    
    private func addProfileImage() {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "Photo")
        image.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        view.addSubview(image)
        self.profileImageView = image
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func addExitButton() {
        let button = UIButton.systemButton(
            with: UIImage(named: "Exit")!,
            target: self,
            action: #selector(Self.didTapExitButton)
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.tintColor = UIColor(named: "YP Red")
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    private func addNameLabel() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 23)
        view.addSubview(label)
        self.nameLabel = label
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func addLoginNameLabel() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.textColor = UIColor(named: "YP Gray")
        label.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(label)
        self.loginNameLabel = label
        
        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func addDescriptionLabel() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, world!"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(label)
        self.descriptionLabel = label
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    @objc
    private func didTapExitButton() {
        for view in view.subviews {
            if view is UILabel {
                view.removeFromSuperview()
            }
        }
        
        profileImageView.image = UIImage(named: "Stub")
    }
}
