import Foundation

final class Cache<Key: Hashable, Value: AnyObject> {
    
    private let cache = NSCache<NSString, AnyObject>()
    
    private func makeKey(_ key: Key) -> NSString {
        "\(key.hashValue)" as NSString
    }
    
    var countLimit: Int {
        get { cache.countLimit }
        set { cache.countLimit = newValue }
    }
    
    var totalCostLimit: Int {
        get { cache.totalCostLimit }
        set { cache.totalCostLimit = newValue }
    }
    
    func value(forKey key: Key) -> Value? {
        return cache.object(forKey: makeKey(key)) as? Value
    }
    
    func setValue(_ value: Value, forKey key: Key) {
        cache.setObject(value, forKey: makeKey(key))
    }
}
