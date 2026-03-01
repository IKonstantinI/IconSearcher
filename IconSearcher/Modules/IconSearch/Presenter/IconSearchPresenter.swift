import Foundation

final class IconSearchPresenter: IconSearchPresenterProtocol {
    
    private weak var view: IconSearchViewProtocol?
    private let iconService: IconServiceProtocol
    private var icons: [Icon] = []
    private var currentPage = 0
    private var totalIcons = 0
    private let pageSize = 30
    private var isLoading = false
    private var currentQuery = ""
    
    init(view: IconSearchViewProtocol, iconService: IconServiceProtocol) {
        self.view = view
        self.iconService = iconService
    }
    
    func viewDidLoad() {
        print("Presenter: View is ready")
    }
    
    func searchButtonTapped(query: String?) {
        guard let query = query, !query.isEmpty else {
            return
        }
        
        view?.showLoading()
        
        currentPage = 0
        totalIcons = 0
        icons = []
        
        currentQuery = query
        fetchIcons(query: currentQuery)
        self.totalIcons =
    }
    
    func didSelectIcon(at index: Int) {
        guard icons.indices.contains(index) else { return }
        let selectedIcon = icons[index]
        print("Presenter: User selected icon \(selectedIcon.fullName)")
    }
    
    private func fetchIcons(query: String) {
        guard !isLoading else { return }
        isLoading = true
        let start = currentPage * pageSize
        iconService.searchIcons(query: query) { [weak self] result in
            guard let self = self else { return }
            
            self.view?.hideLoading()
            
            switch result {
            case .success(let icons):
                let viewModels = self.mapIconsToViewModels(icons: icons)
                if currentPage > 0 {
                    self.icons.append(contentsOf: icons)
                    
                } else {
                    self.view?.showIcons(viewModels: viewModels)
                }
            case .failure(let error):
                view?.showError(title: "Error", message: error.localizedDescription)
            }
            self.isLoading = false
        }
    }
    
    private func mapIconsToViewModels(icons: [Icon]) -> [IconViewModel] {
        return icons.map { icon in
            let sizeText = "\(icon.width)x\(icon.height)"
            let tagsText = "Tags: " + icon.tags.prefix(10).joined(separator: ",")
            let iconURL = URL(string: "https://api.iconify.design/\(icon.fullName).svg")
            return IconViewModel(sizeText: sizeText, tagsText: tagsText, iconImageURL: iconURL)
        }
    }
}
