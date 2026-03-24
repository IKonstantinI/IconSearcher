import XCTest
@testable import IconSearcher

final class IconSearchViewControllerTests: XCTestCase {
    
    var sut: IconSearchViewController!
    var mockPresenter: MockIconSearchPresenter!
    
    override func setUp() {
        super.setUp()
        
        mockPresenter = MockIconSearchPresenter()
        sut = IconSearchViewController(presenter: mockPresenter)
        _ = sut.view
    }
    
    override func tearDown() {
        sut = nil
        mockPresenter = nil
        super.tearDown()
    }
    
    // MARK: - Test: View Loading
    
    func testViewController_LoadsSuccessfully() {
        XCTAssertNotNil(sut.view, "View должен быть загружен")
    }
    
    // MARK: - Test: Search Action
    
    func testSearch_CallsPresenter() {
        sut.searchBarSearchButtonClicked(UISearchBar())
        
        XCTAssertTrue(mockPresenter.searchButtonTappedCalled, "presenter.searchButtonTapped должен быть вызван")
    }
    
    // MARK: - Test: Show Icons
    
    func testShowIcons_DoesNotCrash() {
        let testViewModels = createTestViewModels(count: 5)
        
        sut.showIcons(viewModels: testViewModels)
    }
    
    func testShowIcons_EmptyList() {
        sut.showIcons(viewModels: [])
    }
    
    // MARK: - Test: Screen States
    
    func testRender_LoadingState() {
        sut.render(state: .loading)
    }
    
    func testRender_ErrorState() {
        sut.render(state: .error("Test error"))
    }
    
    func testRender_NoResultState() {
        sut.render(state: .noResult)
    }
    
    func testRender_ShowingContentState() {
        let testViewModels = createTestViewModels(count: 3)
        sut.showIcons(viewModels: testViewModels)
        
        sut.render(state: .showingContent)
    }
    
    // MARK: - Test: Save Notification
    
    func testShowSaveNotification_Success() {
        sut.showSaveNotification(isSuccses: true, message: nil)
    }
    
    func testShowSaveNotification_Failure() {
        sut.showSaveNotification(isSuccses: false, message: "Error message")
    }
    
    // MARK: - Helper Methods
    
    private func createTestViewModels(count: Int) -> [IconViewModel] {
        return (0..<count).map { index in
            IconViewModel(
                sizeText: "512x512",
                tags: ["tag\(index)"],
                iconImageURL: URL(string: "https://example.com/icon\(index).png")
            )
        }
    }
}
