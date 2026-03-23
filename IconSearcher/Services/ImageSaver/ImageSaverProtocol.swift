import UIKit

protocol ImageSaverProtocol {

    func saveImage(from url: URL, completion: @escaping (Result<Void, Error>) -> Void)
}

