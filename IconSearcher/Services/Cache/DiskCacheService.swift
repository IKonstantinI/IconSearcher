import Foundation

final class DiskCacheService: DiskCacheServiceProtocol {
    
    // MARK: - Properties
    
    private let fileManager: FileManager
    private let cacheDirectory: URL
    private let fileQueue = DispatchQueue(label: "com.bertoldi.IconSearcher.diskCacheQueue", qos: .background)
    
    // MARK: - Initialization
    
    init(fileManager: FileManager = .default, directoryName: String) throws {
        self.fileManager = fileManager
        
        guard let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw CacheError.caсheDirectoryNotFound
        }
        
        self.cacheDirectory = cachesURL.appendingPathComponent(directoryName)
        
        try createDirectoryIfNeeded()
    }
    
    // MARK: - Public Methods
    
    func fetch<T: Codable>(forKey key: String, completion: @escaping (Result<T?, Error>) -> Void) {
        let fileURL = filePath(for: key)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            DispatchQueue.main.async { completion(.success(nil)) }
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let value = try JSONDecoder().decode(T.self, from: data)
            DispatchQueue.main.async { completion(.success(value)) }
        } catch {
            DispatchQueue.main.async { completion(.failure(CacheError.decodingFailed(error))) }
        }
    }
    
    func save<T: Codable>(_ value: T, forKey key: String, completion: ((Error?) -> Void)? = nil) {
        fileQueue.async {
            let fileURL = self.filePath(for: key)
            
            do {
                let data = try JSONEncoder().encode(value)
                try data.write(to: fileURL, options: .atomic)
                DispatchQueue.main.async { completion?(nil) }
            } catch {
                let thrownError: CacheError
                if error is EncodingError {
                    thrownError = CacheError.encodingFailed(error)
                } else {
                    thrownError = CacheError.fileSystemError(error)
                }
                DispatchQueue.main.async {
                    completion?(thrownError)
                }
            }
        }
    }
    
    func remove(forKey key: String, completion: ((Error?) -> Void)? = nil) {
        fileQueue.async {
            let fileURL = self.filePath(for: key)
            
            guard self.fileManager.fileExists(atPath: fileURL.path) else {
                DispatchQueue.main.async { completion?(nil) }
                return
            }
            
            do {
                try self.fileManager.removeItem(at: fileURL)
                DispatchQueue.main.async { completion?(nil) }
            } catch {
                DispatchQueue.main.async { completion?(CacheError.fileSystemError(error)) }
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
                        if now.timeIntervalSince(modificationDate) > maxAge {
                            try self.fileManager.removeItem(at: fileURL)
                        }
                    }
                }
            } catch {
                print("Failed to clean up disk cache: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func filePath(for key: String) -> URL {
        let safeKey = Data(key.utf8).base64EncodedString()
        return cacheDirectory.appendingPathComponent(safeKey)
    }
    
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
}

