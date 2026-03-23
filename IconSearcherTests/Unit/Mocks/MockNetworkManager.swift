import Foundation
@testable import IconSearcher

final class MockNetworkManager: NetworkManagerProtocol {
    
    // MARK: - Properties
    
    var requestCalled = false
    var lastRequest: URLRequest?
    var lastURL: URL?
    var requestCallCount = 0
    
    var mockResponse: Result<Any, Error>?
    
    // MARK: - NetworkManagerProtocol
    
    func request<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        requestCalled = true
        lastURL = url
        requestCallCount += 1
        
        if let mockResponse = mockResponse {
            switch mockResponse {
            case .success(let value):
                completion(.success(value as! T))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func request<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        requestCalled = true
        lastRequest = request
        requestCallCount += 1
        
        if let mockResponse = mockResponse {
            switch mockResponse {
            case .success(let value):
                completion(.success(value as! T))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        requestCalled = false
        lastRequest = nil
        lastURL = nil
        requestCallCount = 0
        mockResponse = nil
    }
}
