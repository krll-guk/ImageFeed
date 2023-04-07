import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    var photoURL: String! {
        didSet {
            guard isViewLoaded else { return }
            downloadPhoto()
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        downloadPhoto()
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
        ProgressHUD.dismiss()
        imageView.kf.cancelDownloadTask()
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        let share = UIActivityViewController(
            activityItems: [imageView.image as Any],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func downloadPhoto() {
        guard let url = URL(string: photoURL) else { return }
        ProgressHUD.show()
        
        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self = self else { return }
            ProgressHUD.dismiss()
            switch result {
            case .success(let value):
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure(let error):
                self.showAlertViewController()
                print(error)
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        view.layoutIfNeeded()
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) / 2, 0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}

extension SingleImageViewController: AlertViewControllerDelegate {
    func didTapFirstButton() {
        didTapBackButton()
    }
    
    func didTapSecondButton() {
        downloadPhoto()
    }
    
    private func showAlertViewController() {
        let alertViewController = AlertViewController()
        alertViewController.delegate = self
        alertViewController.modalPresentationStyle = .overFullScreen
        present(alertViewController, animated: false) {
            alertViewController.showError(
                title: "Что-то пошло не так(",
                message: "Попробовать ещё раз?",
                firstButtonText: "Не надо",
                secondButtonText: "Повторить"
            )
        }
    }
}
