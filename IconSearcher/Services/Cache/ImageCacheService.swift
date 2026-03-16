import Foundation

final class ImageCacheService {
    
    // MARK: - Properties
    
    private let fileManager: FileManager
    private let cacheDirectory: URL
    private let fileQueue = DispatchQueue(label: "com.IconSearcher.imageCacheQueue", qos: .background)
    
    // MARK: - Initialization
    
    init(fileManager: FileManager = .default, directoryName: String = "ImageCache") throws {
        self.fileManager = fileManager
        
        guard let cachesUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw CacheError.caсheDirectoryNotFound
        }
        
        self.cacheDirectory = cachesUrl.appendingPathComponent(directoryName)
        
        try createDirectoryIfNeeded()
    }
    
    // MARK: - Public Methods
    
    func save(_ data: Data, forKey key: String, completion: ((Error?) -> Void)? = nil) {
        fileQueue.async {
            let fileURL = self.filePath(for: key)
            
            do {
                try data.write(to: fileURL, options: .atomic)
                
                DispatchQueue.main.async {
                    completion?(nil)
                }
            } catch {
                let cacheError = CacheError.fileSystemError(error)
                DispatchQueue.main.async {
                    completion?(cacheError)
                }
            }
        }
    }
    
    func fetch(forKey key: String, completion: @escaping (Data?) -> Void) {
        fileQueue.async {
            let fileURL = self.filePath(for: key)
            guard self.fileManager.fileExists(atPath: fileURL.path) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            do {
                let data = try Data(contentsOf: fileURL)
                DispatchQueue.main.async {
                    completion(data)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func cleanUp(maxAge: TimeInterval) {
        fileQueue.async {
            let now = Date()
            let resourceKeys: [URLResourceKey] = [.contentModificationDateKey]
            
            do {
                let files = try self.fileManager.contentsOfDirectory(
                    at: self.cacheDirectory,
                    includingPropertiesForKeys: resourceKeys,
                    options: .skipsHiddenFiles
                )
                
                for fileURL in files {
                    let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                    if let modificationDate = resourceValues.contentModificationDate {
                        let age = now.timeIntervalSince(modificationDate)
                        
                        if age > maxAge {
                            try self.fileManager.removeItem(at: fileURL)
                        }
                    }
                }
            } catch {
                print("Failed to clear image cache: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func createDirectoryIfNeeded() throws {
        guard !fileManager.fileExists(atPath: cacheDirectory.path) else {
            return
        }
        
        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            throw CacheError.fileSystemError(error)
        }
    }
    
    private func filePath(for key: String) -> URL {
        let safeKey = Data(key.utf8).base64EncodedString()
        return cacheDirectory.appendingPathComponent(safeKey)
    }
}
