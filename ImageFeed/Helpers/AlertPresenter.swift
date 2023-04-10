import UIKit

final class AlertPresenter {
    static func showAlert(
        vc: UIViewController,
        title: String?,
        message: String?,
        firstButtonText: String?,
        _ completion1: (() -> Void)? = nil,
        secondButtonText: String? = nil,
        _ completion2: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let action1 = UIAlertAction(
            title: firstButtonText,
            style: .default
        ) { _ in
            (completion1 ?? {})()
        }
        alert.addAction(action1)
        
        if secondButtonText != nil {
            let action2 = UIAlertAction(
                title: secondButtonText,
                style: .default
            ) { _ in
                (completion2 ?? {})()
            }
            alert.addAction(action2)
        }
        
        vc.present(alert, animated: true)
    }
}
