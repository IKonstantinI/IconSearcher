import XCTest
@testable import IconSearcher


final class IconSearchPresenterTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: IconSearchPresenter!
    var mockView: MockIconSearchView!
    var mockRepository: MockIconRepository!
    var mockImageSaver: MockImageSaver!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        mockView = MockIconSearchView()
        mockRepository = MockIconRepository()
        mockImageSaver = MockImageSaver()
        
        sut = IconSearchPresenter(
            view: mockView,
            iconRepository: mockRepository,
            imageSaver: mockImageSaver
        )
    }
    
    override func tearDown() {
        sut = nil
        mockView = nil
        mockRepository = nil
        mockImageSaver = nil
        super.tearDown()
    }
    
    // MARK: - Test: searchButtonTapped

    func testSearchButtonTapped_WithValidQuery_SuccessfulSearch() {
        // Arrange
        let testQuery = "vector"
        let testIcons = createTestIcons(count: 5)
        let testTotal = 100
        
        mockRepository.setMockData(icons: testIcons, total: testTotal)
        
        sut.searchButtonTapped(query: testQuery)
        
        XCTAssertTrue(mockRepository.searchIconsCalled, "Repository должен быть вызван")
        XCTAssertEqual(mockRepository.lastQuery, testQuery, "Query должен совпадать")
        XCTAssertEqual(mockRepository.lastLimit, 32, "Limit должен быть равен pageSize")
        XCTAssertEqual(mockRepository.lastStart, 0, "Start должен быть 0 для первой страницы")
        
        XCTAssertTrue(mockView.didShowLoading, "View должен показать loading")
        XCTAssertTrue(mockView.didShowContent, "View должен показать content после успеха")
        XCTAssertEqual(mockView.showIconsCallCount, 1, "showIcons должен быть вызван 1 раз")
        XCTAssertEqual(mockView.lastShowIconsViewModels?.count, 5, "Должно быть 5 иконок")
    }
    
    
    func testSearchButtonTapped_WithEmptyQuery_NoSearchPerformed() {
        sut.searchButtonTapped(query: "")
        
        // Assert
        XCTAssertFalse(mockRepository.searchIconsCalled, "Repository НЕ должен быть вызван")
        XCTAssertEqual(mockView.renderStates.count, 1, "Должно быть только начальное состояние empty")
        XCTAssertEqual(mockView.lastRenderState, .empty, "Состояние должно остаться empty")
    }
    
    func testSearchButtonTapped_WithNilQuery_NoSearchPerformed() {
        sut.searchButtonTapped(query: nil)
        
        XCTAssertFalse(mockRepository.searchIconsCalled, "Repository НЕ должен быть вызван")
    }
    
    
    func testSearchButtonTapped_RepositoryReturnsError_ShowsError() {
        let testQuery = "vector"
        let testError = MockIconRepository.MockError.networkError
        
        mockRepository.setError(testError)
        
        sut.searchButtonTapped(query: testQuery)
        
        XCTAssertTrue(mockRepository.searchIconsCalled, "Repository должен быть вызван")
        XCTAssertTrue(mockView.didShowError, "View должен показать error")
    }
    
    func testSearchButtonTapped_EmptyResult_ShowsNoResult() {
        let testQuery = "nonexistent_query_xyz"
        
        mockRepository.setMockData(icons: [], total: 0)
        
        sut.searchButtonTapped(query: testQuery)
        
        XCTAssertTrue(mockRepository.searchIconsCalled, "Repository должен быть вызван")
        XCTAssertTrue(mockView.didShowNoResult, "View должен показать noResult")
    }
    
    // MARK: - Test: didSelectIcon
    
    
    func testDidSelectIcon_ValidIndex_SuccessfulSave() {
        let testIcons = createTestIcons(count: 5)
        let testIconURL = URL(string: "https://example.com/icon0.png")!
        
        mockRepository.setMockData(icons: testIcons, total: 5)
        sut.searchButtonTapped(query: "test")
        
        mockView.reset()
        
        sut.didSelectIcon(at: 0)
        
        XCTAssertTrue(mockImageSaver.saveImageCalled, "ImageSaver должен быть вызван")
        XCTAssertEqual(mockImageSaver.lastSavedURL, testIconURL, "URL иконки должен совпадать")
        
        XCTAssertEqual(mockView.saveNotificationCallCount, 1, "Уведомление должно быть показано 1 раз")
        XCTAssertEqual(mockView.lastSaveNotification?.isSuccses, true, "Уведомление должно быть об успехе")
    }
    
    func testDidSelectIcon_InvalidIndex_NoAction() {
        let testIcons = createTestIcons(count: 3)
        
        mockRepository.setMockData(icons: testIcons, total: 3)
        sut.searchButtonTapped(query: "test")
        
        sut.didSelectIcon(at: 5)
        
        XCTAssertFalse(mockImageSaver.saveImageCalled, "ImageSaver НЕ должен быть вызван")
        XCTAssertEqual(mockView.saveNotificationCallCount, 0, "Уведомление НЕ должно быть показано")
    }
    
    func testDidSelectIcon_SaveFails_ShowsErrorNotification() {
        let testIcons = createTestIcons(count: 3)
        
        mockRepository.setMockData(icons: testIcons, total: 3)
        sut.searchButtonTapped(query: "test")
        
        mockView.reset()
        mockImageSaver.shouldFail = true
        
        sut.didSelectIcon(at: 0)
        
        XCTAssertTrue(mockImageSaver.saveImageCalled, "ImageSaver должен быть вызван")
        XCTAssertEqual(mockView.saveNotificationCallCount, 1, "Уведомление должно быть показано")
        XCTAssertEqual(mockView.lastSaveNotification?.isSuccses, false, "Уведомление должно быть об ошибке")
    }
    
    // MARK: - Test: scrolledToBottom
    
    func testScrolledToBottom_LoadsNextPage() {
        let testIcons = createTestIcons(count: 32)
        
        mockRepository.setMockData(icons: testIcons, total: 100)
        sut.searchButtonTapped(query: "test")
        
        mockRepository.reset()
        
        // Act
        sut.scrolledToBottom()
        
        XCTAssertTrue(mockRepository.searchIconsCalled, "Repository должен быть вызван")
        XCTAssertEqual(mockRepository.lastStart, 32, "Start должен быть равен pageSize для второй страницы")
    }
    
    // MARK: - Helper Methods
    
    private func createTestIcons(count: Int) -> [Icon] {
        return (0..<count).map { index in
            Icon(
                name: "Icon \(index)",
                tags: ["tag\(index)", "test"],
                url: URL(string: "https://example.com/icon\(index).png")!,
                width: 512,
                height: 512
            )
        }
    }
}
