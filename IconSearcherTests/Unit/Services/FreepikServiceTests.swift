import XCTest
@testable import IconSearcher

/// Тесты для FreepikService
final class FreepikServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: FreepikService!
    var mockNetworkManager: MockNetworkManager!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        mockNetworkManager = MockNetworkManager()
        
        // Используем явный API ключ для тестов
        sut = FreepikService(
            apiKey: "test_api_key_123",
            networkManager: mockNetworkManager
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    // MARK: - Test: Successful Search
    
    /// Тест: Успешный поиск иконок
    func testSearchIcons_Success_ReturnsIcons() {
        // Arrange
        let testQuery = "vector"
        let testResponse = createMockFreepikResponse(count: 5, total: 100)
        
        mockNetworkManager.mockResponse = .success(testResponse)
        
        // Act
        let expectation = XCTestExpectation(description: "Search completes")
        
        sut.searchIcons(query: testQuery, limit: 32, start: 0) { result in
            switch result {
            case .success(let (icons, total)):
                XCTAssertEqual(icons.count, 5, "Должно быть 5 иконок")
                XCTAssertEqual(total, 100, "Total должен быть 100")
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Assert
        XCTAssertTrue(mockNetworkManager.requestCalled, "NetworkManager должен быть вызван")
        XCTAssertEqual(mockNetworkManager.lastRequest?.httpMethod, "GET")
    }
    
    // MARK: - Test: Network Error
    
    /// Тест: Ошибка сети
    func testSearchIcons_NetworkError_ReturnsError() {
        // Arrange
        let testQuery = "vector"
        mockNetworkManager.mockResponse = .failure(NetworkError.noData)
        
        // Act
        let expectation = XCTestExpectation(description: "Search completes with error")
        
        sut.searchIcons(query: testQuery, limit: 32, start: 0) { result in
            switch result {
            case .success:
                XCTFail("Expected error, got success")
            case .failure:
                break
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Assert
        XCTAssertTrue(mockNetworkManager.requestCalled, "NetworkManager должен быть вызван")
    }
    
    // MARK: - Test: Empty Result
    
    /// Тест: Пустой результат
    func testSearchIcons_EmptyResult_ReturnsEmptyArray() {
        // Arrange
        let testQuery = "nonexistent_query_xyz"
        let testResponse = createMockFreepikResponse(count: 0, total: 0)
        
        mockNetworkManager.mockResponse = .success(testResponse)
        
        // Act
        let expectation = XCTestExpectation(description: "Search completes")
        
        sut.searchIcons(query: testQuery, limit: 32, start: 0) { result in
            switch result {
            case .success(let (icons, total)):
                XCTAssertEqual(icons.count, 0, "Должно быть 0 иконок")
                XCTAssertEqual(total, 0, "Total должен быть 0")
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Assert
        XCTAssertTrue(mockNetworkManager.requestCalled, "NetworkManager должен быть вызван")
    }
    
    // MARK: - Test: Pagination
    
    /// Тест: Пагинация (вторая страница)
    func testSearchIcons_Pagination_CorrectStartParameter() {
        // Arrange
        let testQuery = "vector"
        let testResponse = createMockFreepikResponse(count: 32, total: 200)
        
        mockNetworkManager.mockResponse = .success(testResponse)
        
        // Act
        let expectation = XCTestExpectation(description: "Search completes")
        
        // Запрашиваем вторую страницу (start=32)
        sut.searchIcons(query: testQuery, limit: 32, start: 32) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Assert
        XCTAssertTrue(mockNetworkManager.requestCalled, "NetworkManager должен быть вызван")
    }
    
    // MARK: - Helper Methods
    
    /// Создание мок FreepikResponse
    private func createMockFreepikResponse(count: Int, total: Int) -> FreepikResponse {
        let icons = (0..<count).map { index in
            FreepikIcon(
                id: index,
                name: "Icon \(index)",
                tags: (0..<3).map { FreepikTag(name: "tag\($0)", slug: "tag\($0)") },
                thumbnails: [
                    FreepikThumbnail(
                        url: URL(string: "https://example.com/icon\(index).png")!,
                        width: 512,
                        height: 512
                    )
                ]
            )
        }
        
        return FreepikResponse(
            data: icons,
            meta: Meta(
                pagination: Pagination(
                    total: total,
                    currentPage: 1,
                    lastPage: (total / 32) + 1,
                    perPage: 32
                )
            )
        )
    }
}
