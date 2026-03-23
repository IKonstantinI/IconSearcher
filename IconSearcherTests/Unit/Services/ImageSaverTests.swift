import XCTest
@testable import IconSearcher

/// Тесты для ImageSaver
final class ImageSaverTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: ImageSaver!
    var mockDownloader: MockImageDownloader!
    var mockPhotoManager: MockPhotoLibraryManager!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        mockDownloader = MockImageDownloader()
        mockPhotoManager = MockPhotoLibraryManager()
        
        sut = ImageSaver(
            downloader: mockDownloader,
            photoManager: mockPhotoManager
        )
    }
    
    override func tearDown() {
        sut = nil
        mockDownloader = nil
        mockPhotoManager = nil
        super.tearDown()
    }
    
    // MARK: - Test: Successful Save
    
    /// Тест: Успешная загрузка и сохранение
    func testSaveImage_Success_DownloadsAndSaves() {
        // Arrange
        let testURL = URL(string: "https://example.com/icon.png")!
        let testImage = UIImage()
        mockDownloader.mockImage = testImage
        
        // Act
        let expectation = XCTestExpectation(description: "Save completes")
        
        sut.saveImage(from: testURL) { result in
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
        XCTAssertTrue(mockDownloader.downloadCalled, "Downloader должен быть вызван")
        XCTAssertEqual(mockDownloader.lastURL, testURL, "URL должен совпадать")
        XCTAssertTrue(mockPhotoManager.saveCalled, "PhotoManager должен быть вызван")
        XCTAssertEqual(mockPhotoManager.lastImage, testImage, "Изображение должно совпадать")
    }
    
    // MARK: - Test: Download Fails
    
    /// Тест: Ошибка загрузки
    func testSaveImage_DownloadFails_DoesNotSave() {
        // Arrange
        let testURL = URL(string: "https://example.com/icon.png")!
        mockDownloader.shouldFail = true
        
        // Act
        let expectation = XCTestExpectation(description: "Save completes with error")
        
        sut.saveImage(from: testURL) { result in
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
        XCTAssertTrue(mockDownloader.downloadCalled, "Downloader должен быть вызван")
        XCTAssertFalse(mockPhotoManager.saveCalled, "PhotoManager НЕ должен быть вызван")
    }
    
    // MARK: - Test: Save Fails
    
    /// Тест: Ошибка сохранения
    func testSaveImage_SaveFails_ReturnsError() {
        // Arrange
        let testURL = URL(string: "https://example.com/icon.png")!
        mockPhotoManager.shouldFail = true
        
        // Act
        let expectation = XCTestExpectation(description: "Save completes with error")
        
        sut.saveImage(from: testURL) { result in
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
        XCTAssertTrue(mockDownloader.downloadCalled, "Downloader должен быть вызван")
        XCTAssertTrue(mockPhotoManager.saveCalled, "PhotoManager должен быть вызван")
    }
    
    // MARK: - Test: Weak Self Handling
    
    /// Тест: Корректная обработка weak self
    func testSaveImage_WeakSelfHandling() {
        // Arrange
        let testURL = URL(string: "https://example.com/icon.png")!
        
        // Act
        let expectation = XCTestExpectation(description: "Save completes")
        
        sut.saveImage(from: testURL) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Assert
        XCTAssertTrue(mockDownloader.downloadCalled, "Downloader должен быть вызван")
        XCTAssertTrue(mockPhotoManager.saveCalled, "PhotoManager должен быть вызван")
    }
}
