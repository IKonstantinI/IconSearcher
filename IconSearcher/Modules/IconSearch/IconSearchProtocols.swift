import Foundation

protocol IconSearchViewProtocol: AnyObject {
    func showIcons(viewModels: [IconViewModel])
    func showLoading()
    func hideLoading()
    func showAlert(title: String, message: String)
}

protocol IconSearchPresenterProtocol: AnyObject {
    func viewDidLoad()
    func searchButtonTapped(query: String?)
    func didSelectIcon(at index: Int)
    func scrolledToButtom()
    func viewModel(at index: Int) -> IconViewModel?
}


