import UIKit

@objc protocol AlertViewControllerDelegate: AnyObject {
    @objc optional func didTapFirstButton()
    @objc optional func didTapSecondButton()
}

final class AlertViewController: UIViewController {
    weak var delegate: AlertViewControllerDelegate?
    
    func showError(
        title: String?,
        message: String?,
        firstButtonText: String?,
        secondButtonText: String? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let action1 = UIAlertAction(
            title: firstButtonText,
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: false) {
                (self.delegate?.didTapFirstButton ?? {})()
            }
        }
        alert.addAction(action1)
        
        if secondButtonText != nil {
            let action2 = UIAlertAction(
                title: secondButtonText,
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: false) {
                    (self.delegate?.didTapSecondButton ?? {})()
                }
            }
            alert.addAction(action2)
        }
        
        self.present(alert, animated: true)
    }
}
