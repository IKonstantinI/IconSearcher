import UIKit

protocol IconCellPresenterProtocol {
    func loadImage(from url: URL?, to imageView: UIImageView)
}

final class IconCellPresenter: IconCellPresenterProtocol {
    
    private let imageLoader: ImageLoaderProtocol = ImageLoader.shared
    private var currentImageURL: URL?
    
    func loadImage(from url: URL?, to imageView: UIImageView) {
        self.currentImageURL = url
        
        imageView.image = nil
        
        guard let url = url else { return }
        
        imageLoader.loadImage(from: url) { [weak self, weak imageView] image in
            
            guard let self = self, let imageView = imageView else { return }
            
            guard self.currentImageURL == url else { return }
            
            imageView.image = image
        }
    }
    
    func cancleOngoingLoad() {
        if let url = currentImageURL {
            imageLoader.cancelLoad(for: url)
        }
        currentImageURL = nil
    }
}
