import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    var tableView: UITableView! { get set }
    var placeholder: UIImage { get set }
    var likeButtonOn: UIImage { get set }
    var likeButtonOff: UIImage { get set }
    func showLoadError()
    func showLikeError()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    
    @IBOutlet var tableView: UITableView!
    
    var placeholder: UIImage = UIImage(named: "photo_placeholder")!
    var likeButtonOn: UIImage = UIImage(named: "likeButtonOn")!
    var likeButtonOff: UIImage = UIImage(named: "likeButtonOff")!
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            viewController.photoURL = presenter?.photos[indexPath.row].largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photoSize = presenter!.photos[indexPath.row].size
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photoSize.width
        let cellHeight = photoSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.loadPhotosNextPage(indexPath: indexPath)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter!.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        presenter?.configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        presenter?.setLike(cell)
    }
}

extension ImagesListViewController {
    func showLoadError() {
        AlertPresenter.showAlert(
            vc: self,
            title: "Что-то пошло не так(",
            message: "Не удалось загрузить фото",
            firstButtonText: "ОК", { [weak self] in
                guard let self = self else { return }
                UIBlockingProgressHUD.show()
                self.tableView.reloadData()
            }
        )
    }
    
    func showLikeError() {
        AlertPresenter.showAlert(
            vc: self,
            title: "Что-то пошло не так(",
            message: "Не удалось поставить лайк",
            firstButtonText: "ОК"
        )
    }
}
