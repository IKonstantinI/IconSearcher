import Foundation
@testable import IconSearcher

final class MockIconSearchPresenter: IconSearchPresenterProtocol {
    
    // MARK: - Properties для отслеживания вызовов
    
    var searchButtonTappedCalled = false
    
    var lastSearchQuery: String?
    
    var didSelectIconCalled = false
    
    var lastSelectedIconIndex: Int?
    
    var scrolledToBottomCalled = false
    
    var searchButtonTappedCallCount = 0
    
    var didSelectIconCallCount = 0
    
    // MARK: - IconSearchPresenterProtocol Methods
    
    func searchButtonTapped(query: String?) {
        searchButtonTappedCalled = true
        lastSearchQuery = query
        searchButtonTappedCallCount += 1
    }
    
    func didSelectIcon(at index: Int) {
        didSelectIconCalled = true
        lastSelectedIconIndex = index
        didSelectIconCallCount += 1
    }
    
    func scrolledToBottom() {
        scrolledToBottomCalled = true
    }
    
    // MARK: - Helper Methods для тестов
    
    func reset() {
        searchButtonTappedCalled = false
        lastSearchQuery = nil
        didSelectIconCalled = false
        lastSelectedIconIndex = nil
        scrolledToBottomCalled = false
        searchButtonTappedCallCount = 0
        didSelectIconCallCount = 0
    }
}
