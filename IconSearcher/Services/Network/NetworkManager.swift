import Foundation

final class NetworkManager: @unchecked Sendable, NetworkManagerProtocol {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Initalization
    
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }
    
    // MARK: - NetworkManagerProtocol
    
    func request<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        let urlRequest = URLRequest(url: url)
        self.request(with: urlRequest, completion: completion)
    }
    
    func request<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            let completionOnMain: (Result<T, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            if let error = error {
                completionOnMain(.failure(NetworkError.other(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionOnMain(.failure(NetworkError.invalidURL))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completionOnMain(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completionOnMain(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decodedObject = try self.decoder.decode(T.self, from: data)
                completionOnMain(.success(decodedObject))
            } catch {
                completionOnMain(.failure(NetworkError.decodingError(error)))
            }
        }
        task.resume()
    }
}
