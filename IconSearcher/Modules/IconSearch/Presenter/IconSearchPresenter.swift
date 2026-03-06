import Foundation

final class IconSearchPresenter: IconSearchPresenterProtocol {
    
    private weak var view: IconSearchViewProtocol?
    private let iconService: IconServiceProtocol
    private var icons: [Icon] = []
    private var currentPage = 0
    private var totalIcons = 0
    private let pageSize = 32
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
        guard let query = query, !query.isEmpty else { return }
        
        view?.showLoading()
        
        currentPage = 0
        totalIcons = 0
        icons = []
        currentQuery = query
        
        loadMoreIcons()
    }
    
    func didSelectIcon(at index: Int) {
        guard icons.indices.contains(index) else { return }
        let selectedIcon = icons[index]
        print("Presenter: User selected icon \(selectedIcon.fullName)")
    }
    
    func scrolledToButtom() {
        loadMoreIcons()
    }
    
    func loadMoreIcons() {
        guard !isLoading else { return }
        
        if currentPage > 0, icons.count >= totalIcons { return }
        
        isLoading = true
        
        if currentPage == 0 {
            view?.showLoading()
        }
        
        let start = currentPage * pageSize
        
        iconService.searchIcons(query: currentQuery, limit: pageSize, start: start) { [weak self] result in
            guard let self = self else { return }
            
            self.view?.hideLoading()
            self.isLoading = false
            
            switch result {
            case .success(let (newIcons, total)):
                if self.currentPage == 0 {
                    self.totalIcons = total
                }
                self.icons.append(contentsOf: newIcons)
                self.currentPage += 1
                
                let viewModels = self.mapIconsToViewModels(icons: self.icons)
                self.view?.showIcons(viewModels: viewModels)
            case .failure(let error):
                if self.currentPage == 0 {
                    self.view?.showError(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func mapIconsToViewModels(icons: [Icon]) -> [IconViewModel] {
        return icons.map { icon in
            let sizeText = "\(icon.width)x\(icon.height)"
            let tagsText = "Tags: " + icon.tags.prefix(10).joined(separator: ",")
            let iconURL = URL(string: "https://api.iconify.design/\(icon.fullName).png?height=48")
            return IconViewModel(sizeText: sizeText, tagsText: tagsText, iconImageURL: iconURL)
        }
    }
}

