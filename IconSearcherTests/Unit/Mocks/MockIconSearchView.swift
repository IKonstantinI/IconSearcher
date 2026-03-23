import Foundation
@testable import IconSearcher

final class MockIconSearchView: IconSearchViewProtocol {
    
    // MARK: - Properties для отслеживания вызовов
    
    var lastRenderState: ScreenState?
    
    var renderStates: [ScreenState] = []
    
    var lastShowIconsViewModels: [IconViewModel]?
    
    var showIconsCallCount = 0
    
    var lastSaveNotification: (isSuccses: Bool, message: String?)?
    
    var saveNotificationCallCount = 0
    
    // MARK: - IconSearchViewProtocol Methods
    
    func showIcons(viewModels: [IconViewModel]) {
        lastShowIconsViewModels = viewModels
        showIconsCallCount += 1
    }
    
    func render(state: ScreenState) {
        lastRenderState = state
        renderStates.append(state)
    }
    
    func showSaveNotification(isSuccses: Bool, message: String?) {
        lastSaveNotification = (isSuccses, message)
        saveNotificationCallCount += 1
    }
    
    // MARK: - Helper Methods для тестов
    
    func reset() {
        lastRenderState = nil
        renderStates = []
        lastShowIconsViewModels = nil
        showIconsCallCount = 0
        lastSaveNotification = nil
        saveNotificationCallCount = 0
    }
    
    func didRender(state: ScreenState) -> Bool {
        return renderStates.contains { compareStates($0, state) }
    }
    
    var didShowLoading: Bool {
        return didRender(state: .loading)
    }
    
    var didShowContent: Bool {
        return didRender(state: .showingContent)
    }
    
    var didShowError: Bool {
        return renderStates.contains { state in
            if case .error = state { return true }
            return false
        }
    }
    
    var didShowNoResult: Bool {
        return didRender(state: .noResult)
    }
    
    // MARK: - Private Methods
    
    private func compareStates(_ lhs: ScreenState, _ rhs: ScreenState) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty),
             (.noResult, .noResult),
             (.loading, .loading),
             (.showingContent, .showingContent):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
