import Foundation
@testable import IconSearcher

final class MockIconRepository: IconRepositoryProtocol {
    
    // MARK: - Properties
    
    var shouldReturnError = false
    
    var errorToReturn: Error?
    
    var mockIcons: [Icon] = []
    
    var mockTotal: Int = 0
    
    // MARK: - Properties для отслеживания вызовов
    
    var searchIconsCalled = false
    
    var lastQuery: String?
    
    var lastLimit: Int?
    
    var lastStart: Int?
    
    var searchIconsCallCount = 0
    
    // MARK: - IconRepositoryProtocol Methods
    
    func searchIcons(
        query: String,
        limit: Int,
        start: Int,
        completion: @escaping (Result<([Icon], total: Int), Error>) -> Void
    ) {
        searchIconsCalled = true
        lastQuery = query
        lastLimit = limit
        lastStart = start
        searchIconsCallCount += 1
        
        if shouldReturnError {
            completion(.failure(errorToReturn ?? MockError.unknownError))
        } else {
            completion(.success((mockIcons, mockTotal)))
        }
    }
    
    // MARK: - Helper Methods для тестов
    
    func reset() {
        searchIconsCalled = false
        lastQuery = nil
        lastLimit = nil
        lastStart = nil
        searchIconsCallCount = 0
    }
    

    func setMockData(icons: [Icon], total: Int) {
        mockIcons = icons
        mockTotal = total
    }
    

    func setError(_ error: Error) {
        errorToReturn = error
        shouldReturnError = true
    }
    
    // MARK: - Mock Errors
    
    enum MockError: LocalizedError {
        case unknownError
        case networkError
        case emptyResult
        
        var errorDescription: String? {
            switch self {
            case .unknownError:
                return "Неизвестная ошибка"
            case .networkError:
                return "Ошибка сети"
            case .emptyResult:
                return "Пустой результат"
            }
        }
    }
}
