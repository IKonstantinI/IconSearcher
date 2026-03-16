import Foundation

protocol DiskCacheServiceProtocol {
    func fetch<T: Codable>(forKey key: String, completion: @escaping (Result<T?, Error>) -> Void)
    func save<T: Codable>(_ value: T, forKey key: String, completion: ((Error?) -> Void)?)
    func remove(forKey key: String, completion: ((Error?) -> Void)?)
    func cleanUp(maxAge: TimeInterval)
}
