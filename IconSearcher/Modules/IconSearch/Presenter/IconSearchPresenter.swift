import Foundation

final class IconSearchPresenter: IconSearchPresenterProtocol {
    
    
    // MARK: - Properties
    
    private weak var view: IconSearchViewProtocol?
    
    private let imageSaver: ImageSaver
    private let iconRepository: IconRepositoryProtocol
    
    private var icons: [Icon] = []
    private var currentPage = 0
    private var totalIcons = 0
    private let pageSize = 32
    private var isLoading = false
    private var currentQuery = ""
    
    // MARK: - Initalization
    
    init(view: IconSearchViewProtocol, iconRepository: IconRepositoryProtocol, imageSaver: ImageSaver = ImageSaver()) {
        self.view = view
        self.iconRepository = iconRepository
        self.imageSaver = imageSaver
        view.render(state: .empty)
    }
    
    // MARK: - IconSearchPresenterProtocol
    
    func searchButtonTapped(query: String?) {
        guard let query = query, !query.isEmpty else { return }
        
        view?.render(state: .loading)
        
        currentPage = 0
        totalIcons = 0
        icons = []
        currentQuery = query
        
        loadMoreIcons()
    }
    
    func didSelectIcon(at index: Int) {
        guard icons.indices.contains(index) else { return }
        let selectedIcon = icons[index]
        
        imageSaver.saveImage(from: selectedIcon.url) { [weak self] result in
            switch result {
            case .success:
                self?.view?.showSaveNotification(isSuccses: true, message: nil)
            case .failure(let error):
                self?.view?.showSaveNotification(isSuccses: false, message: error.localizedDescription)
            }
        }
    }
    
    func scrolledToBottom() {
        loadMoreIcons()
    }
    
    // MARK: - Private Methods
    
    private func loadMoreIcons() {
        guard !isLoading else { return }
        
        if currentPage > 0, icons.count >= totalIcons { return }
        
        isLoading = true
        
        if currentPage == 0 {
            view?.render(state: .loading)
        }
        
        let start = currentPage * pageSize
        
        iconRepository.searchIcons(query: currentQuery, limit: pageSize, start: start) { [weak self] result in
            guard let self = self else { return }
            
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
                
                if self.icons.isEmpty {
                    self.view?.render(state: .noResult)
                } else {
                    self.view?.render(state: .showingContent)
                }
                
            case .failure(let error):
                if self.currentPage == 0 {
                    self.view?.render(state: .error(error.localizedDescription))
                }
            }
        }
    }
    
    private func mapIconsToViewModels(icons: [Icon]) -> [IconViewModel] {
        return icons.map { icon in
            let sizeText = "\(icon.width)x\(icon.height)"
            let topTenTags = Array(icon.tags.prefix(10))
            
            return IconViewModel(
                sizeText: sizeText,
                tags: topTenTags,
                iconImageURL: icon.url
            )
        }
    }
}

