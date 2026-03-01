import Foundation

protocol IconServiceProtocol {
    func searchIcons(query: String, completion: @escaping (Result<[Icon], Error>) -> Void)
}
