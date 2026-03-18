import Foundation

protocol IconSearchViewProtocol: AnyObject {
    func showIcons(viewModels: [IconViewModel])
    func render(state: ScreenState)
    func showSaveNotification(isSuccses: Bool, message: String?)
}

protocol IconSearchPresenterProtocol: AnyObject {
    func searchButtonTapped(query: String?)
    func didSelectIcon(at index: Int)
    func scrolledToBottom()
}

enum ScreenState {
    case empty
    case noResult
    case loading
    case showingContent
    case error(String)
}

