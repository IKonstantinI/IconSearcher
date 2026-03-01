import Foundation

protocol IconSearchViewProtocol: AnyObject {
    func showIcons(viewModels: [IconViewModel])
    func showLoading()
    func hideLoading()
    func showError(title: String, message: String)
}

protocol IconSearchPresenterProtocol: AnyObject {
    func viewDidLoad()
    func searchButtonTapped(query: String?)
    func didSelectIcon(at index: Int)
}


