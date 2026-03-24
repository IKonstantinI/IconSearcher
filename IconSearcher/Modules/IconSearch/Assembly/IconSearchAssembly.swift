import UIKit

final class IconSearchAssembly {

    static func assemble() -> IconSearchViewController {
        // Создаем FreepikService через factory
        guard let networkService = FreepikServiceFactory.makeDefault() else {
            fatalError("Failed to create FreepikService. Check Keys.plist")
        }

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
