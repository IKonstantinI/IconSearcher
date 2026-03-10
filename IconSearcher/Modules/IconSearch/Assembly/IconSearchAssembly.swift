import UIKit

final class IconSearchAssembly {
    
    static func assemble() -> IconSearchViewController {
        let networkService = FreepikService()
        let cachedService = RequestCacheService()
        
        let iconRepository = IconRepository(
            networkService: networkService,
            cacheService: cachedService
        )
        
        let viewController = IconSearchViewController(presenter: nil)
        let presenter = IconSearchPresenter(
            view: viewController,
            iconRepository: iconRepository
        )
        
        viewController.presenter = presenter
        
        return viewController
    }
}
