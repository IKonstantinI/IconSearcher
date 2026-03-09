import Foundation

struct CachedIconsResponse: Codable {
    let icons: [Icon]
    let total: Int
}

protocol RequestCacheServiceProtocol {
    func getCachedResponse(for query: String) -> CachedIconsResponse?
    func cacheResponse(_ response: CachedIconsResponse, for query: String)
}

final class RequestCacheService: RequestCacheServiceProtocol {
    
    private let fileManager = FileManager.default
    private let cachedDirectory: URL
    
    init() {
        if let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            self.cachedDirectory = url.appendingPathComponent("IconsSearchesCache")
            try? fileManager.createDirectory(at: self.cachedDirectory, withIntermediateDirectories: true)
        } else {
            fatalError("Не удалось найти системную директорию кеша.")
        }
    }
    
    private func filePath(for query: String) -> URL {
        let safeFileName = Data(query.utf8).base64EncodedString()
        return cachedDirectory.appendingPathComponent(safeFileName)
    }
    
    func getCachedResponse(for query: String) -> CachedIconsResponse? {
        let fileURL = filePath(for: query)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let cachedResponse = try JSONDecoder().decode(CachedIconsResponse.self, from: data)
            print("Загружен кешированный ответ для запроса '\(query)'.")
            return cachedResponse
        } catch {
            print("Ошибка загрузки кеша: \(error.localizedDescription). Удаляем поврежденный файл.")
            try? fileManager.removeItem(at: fileURL)
            return nil
        }
    }
    
    func cacheResponse(_ response: CachedIconsResponse, for query: String) {
        let fileURL = filePath(for: query)
        
        do {
            let data = try JSONEncoder().encode(response)
            try data.write(to: fileURL, options: .atomic)
            print("Ответ для запроса '\(query)' успешно закеширован.")
        } catch {
            print("Ошибка кеширования ответа: \(error.localizedDescription)")
        }
    }
}
