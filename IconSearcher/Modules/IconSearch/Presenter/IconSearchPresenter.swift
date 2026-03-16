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
    }
    
    // MARK: - IconIconSearchPresenterProtocol
    
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
        
        view?.showLoading()
        
        imageSaver.saveImage(from: selectedIcon.url) { [weak self] result in
            self?.view?.hideLoading()
            
            switch result {
            case .success:
                self?.view?.showAlert(title: "Ok", message: "Иконка была сохранена в галерею.")
            case .failure(let error):
                self?.view?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func scrolledToButtom() {
        loadMoreIcons()
    }
    
    func viewModel(at index: Int) -> IconViewModel? {
        guard icons.indices.contains(index) else { return nil }
        let icon = icons[index]
        return mapIconsToViewModels(icons: [icon]).first
    }
    
    // MARK: - Private Metthods
    
    private func loadMoreIcons() {
        guard !isLoading else { return }
        
        if currentPage > 0, icons.count >= totalIcons { return }
        
        isLoading = true
        
        if currentPage == 0 {
            view?.showLoading()
        }
        
        let start = currentPage * pageSize
        
        iconRepository.searchIcons(query: currentQuery, limit: pageSize, start: start) { [weak self] result in
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
                    self.view?.showAlert(title: "Error", message: error.localizedDescription)
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

