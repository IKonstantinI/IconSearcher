import Foundation

protocol NetworkManagerProtocol {
    func request<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void)
    
    func request<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void)
}
