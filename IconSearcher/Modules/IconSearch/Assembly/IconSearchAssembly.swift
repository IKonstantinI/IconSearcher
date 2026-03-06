import UIKit

final class IconSearchAssembly {
    
    static func assemble() -> IconSearchViewController {
        let networkManager = NetworkManager()
        let iconService = FreepikService(networkManager: networkManager)
        let viewController = IconSearchViewController(presenter: nil)
        let presenter = IconSearchPresenter(view: viewController, iconService: iconService)
        
        viewController.presenter = presenter
        
        return viewController
    }
}
