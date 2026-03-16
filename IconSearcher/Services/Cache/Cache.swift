import Foundation

final class Cache<Key: Hashable, Value: AnyObject> {
    
    // MARK: - Properties
    
    private let cache = NSCache<WrappedKey, Value>()
    
    // MARK: - Wrapped Key
    
    private final class WrappedKey: NSObject {
        let key: Key
        init(_ key: Key) { self.key = key }
        override var hash: Int { key.hashValue }
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else { return false }
            return value.key == key
        }
    }
    
    // MARK: - Configuration
    
    var countLimit: Int {
        get { cache.countLimit }
        set { cache.countLimit = newValue }
    }
    
    var totalCostLimit: Int {
        get { cache.totalCostLimit }
        set { cache.totalCostLimit = newValue }
    }
    
    // MARK: - Public Methods
    
    func value(forKey key: Key) -> Value? {
        let wrappedKey = WrappedKey(key)
        return cache.object(forKey: wrappedKey)
    }
    
    func setValue(_ value: Value, forKey key: Key) {
        let wrappedKey = WrappedKey(key)
        cache.setObject(value, forKey: wrappedKey)
    }
    
    func removeValue(forKey key: Key) {
        let wrappedKey = WrappedKey(key)
        cache.removeObject(forKey: wrappedKey)
    }
    
    func removeAll() {
        cache.removeAllObjects()
    }
}

// MARK: - Subscript

extension Cache {
    subscript(key: Key) -> Value? {
        get {
            return value(forKey: key)
        }
        set {
            if let value = newValue {
                setValue(value, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
}
