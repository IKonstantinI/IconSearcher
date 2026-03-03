import UIKit

protocol IconCellPresenterProtocol {
    func loadImage(from url: URL?, to imageView: UIImageView)
    func cancelLoad()
}

final class IconCellPresenter: IconCellPresenterProtocol {
    
    private let imageLoader: ImageLoaderProtocol
    
    init(imageLoader: ImageLoaderProtocol = ImageLoader()) {
        self.imageLoader = imageLoader
    }
    
    func loadImage(from url: URL?, to imageView: UIImageView) {
        guard let url = url else {
            imageView.image = nil
            return
        }
        
        imageLoader.loadImage(from: url) { [weak self] image in
            guard self != nil else { return }
            imageView.image = image
        }
    }
    
    func cancelLoad() {
        imageLoader.cancelLoad()
    }
}
