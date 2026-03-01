import Foundation

protocol NetworkManagerProtocol {
    func request<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void)
}
