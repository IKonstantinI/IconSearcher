import XCTest
@testable import IconSearcher

/// Тесты для ImageLoader
final class ImageLoaderTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: ImageLoader!
    var mockCache: MockImageCachingService!
    var mockDownloader: MockImageDownloadManager!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        mockCache = MockImageCachingService()
        mockDownloader = MockImageDownloadManager()
        
        sut = ImageLoader(cache: mockCache, downloader: mockDownloader)
    }
    
    override func tearDown() {
        sut = nil
        mockCache = nil
        mockDownloader = nil
        super.tearDown()
    }
    
    // MARK: - Test: Cache Hit
    
    /// Тест: Изображение найдено в кэше
    func testLoadImage_CacheHit_ReturnsCachedImage() {
        // Arrange
        let testURL = URL(string: "https://example.com/icon.png")!
        let testImage = UIImage()
        mockCache.cachedImage = testImage
        
        // Act
        let expectation = XCTestExpectation(description: "Image loaded")
        
        sut.loadImage(from: testURL) { image in
            XCTAssertNotNil(image, "Image должна быть")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Assert
        XCTAssertTrue(mockCache.getImageCalled, "Кэш должен быть проверен")
        XCTAssertFalse(mockDownloader.downloadCalled, "Загрузка не должна быть вызвана")
    }
    
    // MARK: - Test: Cache Miss
    
    /// Тест: Изображение не найдено в кэше — загрузка из сети
    func testLoadImage_CacheMiss_DownloadsImage() {
        // Arrange
        let testURL = URL(string: "https://example.com/icon.png")!
        let testImage = UIImage(systemName: "photo")! // Валидный image с данными
        mockCache.cachedImage = nil
        mockDownloader.downloadedImage = testImage
        
        // Act
        let expectation = XCTestExpectation(description: "Image loaded")
        
        sut.loadImage(from: testURL) { image in
            XCTAssertNotNil(image, "Image должна быть")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Assert
        XCTAssertTrue(mockCache.getImageCalled, "Кэш должен быть проверен")
        XCTAssertTrue(mockDownloader.downloadCalled, "Загрузка должна быть вызвана")
    }
    
    // MARK: - Test: Save to Cache
    
    /// Тест: Загруженное изображение сохраняется в кэш
    func testLoadImage_DownloadedImage_SavesToCache() {
        // Arrange
        let testURL = URL(string: "https://example.com/icon.png")!
        let testImage = UIImage(systemName: "photo")! // Валидный image с данными
        mockCache.cachedImage = nil
        mockDownloader.downloadedImage = testImage
        
        // Act
        let expectation = XCTestExpectation(description: "Image loaded")
        
        sut.loadImage(from: testURL) { image in
            XCTAssertNotNil(image, "Image должна быть")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Assert
        XCTAssertTrue(mockCache.saveImageCalled, "Изображение должно быть сохранено в кэш")
    }
    
    // MARK: - Test: Cancel Load
    
    /// Тест: Отмена загрузки
    func testCancelLoad_CallsDownloader() {
        // Arrange
        let testURL = URL(string: "https://example.com/icon.png")!
        
        // Act
        sut.cancelLoad(for: testURL)
        
        // Assert
        XCTAssertTrue(mockDownloader.cancelLoadCalled, "Отмена загрузки должна быть вызвана")
    }
    
    // MARK: - Test: Nil Image from Downloader
    
    /// Тест: Загрузка вернула nil
    func testLoadImage_DownloaderReturnsNil_CompletesWithNil() {
        // Arrange
        let testURL = URL(string: "https://example.com/icon.png")!
        mockCache.cachedImage = nil
        mockDownloader.downloadedImage = nil
        
        // Act
        let expectation = XCTestExpectation(description: "Image loaded")
        
        sut.loadImage(from: testURL) { image in
            XCTAssertNil(image, "Image должен быть nil")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Assert
        XCTAssertTrue(mockDownloader.downloadCalled, "Загрузка должна быть вызвана")
    }
    
    // MARK: - Test: Multiple Requests Same URL
    
    /// Тест: Несколько запросов одного URL
    func testLoadImage_MultipleRequestsSameURL() {
        // Arrange
        let testURL = URL(string: "https://example.com/icon.png")!
        let testImage = UIImage(systemName: "photo")! // Валидный image с данными
        mockCache.cachedImage = nil
        mockDownloader.downloadedImage = testImage
        
        // Act
        let expectation1 = XCTestExpectation(description: "Request 1")
        let expectation2 = XCTestExpectation(description: "Request 2")
        
        sut.loadImage(from: testURL) { image in
            XCTAssertNotNil(image, "Image 1 должна быть")
            expectation1.fulfill()
        }
        
        sut.loadImage(from: testURL) { image in
            XCTAssertNotNil(image, "Image 2 должна быть")
            expectation2.fulfill()
        }
        
        wait(for: [expectation1, expectation2], timeout: 2.0)
        
        // Assert
        XCTAssertTrue(mockCache.getImageCalled, "Кэш должен быть проверен")
        XCTAssertTrue(mockDownloader.downloadCalled, "Загрузка должна быть вызвана")
    }
}
