import XCTest
@testable import IconSearcher

final class IconSearcherTests: XCTestCase {
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Model Tests
    
    func testIcon_Creation() {
        let testURL = URL(string: "https://example.com/icon.png")!
        
        let icon = Icon(
            name: "Test Icon",
            tags: ["test", "example"],
            url: testURL,
            width: 512,
            height: 512
        )
        
        XCTAssertEqual(icon.name, "Test Icon", "Name должен совпадать")
        XCTAssertEqual(icon.tags.count, 2, "Должно быть 2 тега")
        XCTAssertEqual(icon.tags.first, "test", "Первый тег должен быть 'test'")
        XCTAssertEqual(icon.width, 512, "Width должен быть 512")
        XCTAssertEqual(icon.height, 512, "Height должен быть 512")
        XCTAssertEqual(icon.url, testURL, "URL должен совпадать")
    }
    
    func testIconViewModel_Creation() {
        let testURL = URL(string: "https://example.com/icon.png")!
        
        let viewModel = IconViewModel(
            sizeText: "512x512",
            tags: ["ui", "vector"],
            iconImageURL: testURL
        )
        
        XCTAssertEqual(viewModel.sizeText, "512x512", "SizeText должен совпадать")
        XCTAssertEqual(viewModel.tags.count, 2, "Должно быть 2 тега")
        XCTAssertEqual(viewModel.iconImageURL, testURL, "URL должен совпадать")
    }
    
    @MainActor
    func testScreenState_Equatable() {
        XCTAssertEqual(ScreenState.empty, ScreenState.empty)
        XCTAssertEqual(ScreenState.loading, ScreenState.loading)
        XCTAssertEqual(ScreenState.noResult, ScreenState.noResult)
        XCTAssertEqual(ScreenState.showingContent, ScreenState.showingContent)
        XCTAssertEqual(ScreenState.error("test"), ScreenState.error("test"))
        
        XCTAssertNotEqual(ScreenState.empty, ScreenState.loading)
        XCTAssertNotEqual(ScreenState.error("test1"), ScreenState.error("test2"))
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_IconCreation() {
        self.measure {
            let icons = (0..<100).map { index in
                Icon(
                    name: "Icon \(index)",
                    tags: ["tag\(index)"],
                    url: URL(string: "https://example.com/icon\(index).png")!,
                    width: 512,
                    height: 512
                )
            }
            _ = icons.count
        }
    }
    
    func testPerformance_ViewModelMapping() {
        let icons = (0..<100).map { index in
            Icon(
                name: "Icon \(index)",
                tags: ["tag\(index)"],
                url: URL(string: "https://example.com/icon\(index).png")!,
                width: 512,
                height: 512
            )
        }
        
        self.measure {
            let viewModels = icons.map { icon in
                IconViewModel(
                    sizeText: "\(icon.width)x\(icon.height)",
                    tags: icon.tags,
                    iconImageURL: icon.url
                )
            }
            _ = viewModels.count
        }
    }
}
