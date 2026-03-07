import Foundation

final class NetworkManager: NetworkManagerProtocol {
    
    private let session: URLSession
    
    init(
        memoryCapacity: Int = 50 * 1024 * 1024,
        diskCapacity: Int = 100 * 1024 * 1024
    ) {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: configuration)
    }
    
    func request<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        let task = session.dataTask(with: url) { data, responce, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(URLError(.cannotParseResponse)))
                    return
                }
                
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func request<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data else {
                    completion(.failure(URLError(.cannotParseResponse)))
                    return
                }
                
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
