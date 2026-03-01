import Foundation

final class IconSearchPresenter: IconSearchPresenterProtocol {
    
    private weak var view: IconSearchViewProtocol?
    private let iconService: IconServiceProtocol
    private var icons: [Icon] = []
    
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
        
        iconService.searchIcons(query: query, completion: { [weak self] result in
            guard let self = self else { return }
            
            self.view?.hideLoading()
            
            switch result {
            case .success(let icons):
                self.icons = icons
                let viewModels = self.mapIconsToViewModels(icons: icons)
                self.view?.showIcons(viewModels: viewModels)
            case .failure(let error):
                view?.showError(title: "Error", message: error.localizedDescription)
            }
        })
    }
    
    func didSelectIcon(at index: Int) {
        guard icons.indices.contains(index) else { return }
        let selectedIcon = icons[index]
        print("Presenter: User selected icon \(selectedIcon.fullName)")
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
