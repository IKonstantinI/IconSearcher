import Foundation

final class Cache<Key: Hashable, Value: AnyClass> {
    
    private let cache = NSCache<NSObject, AnyObject>()
    
    var countLimit: Int {
        get { cache.countLimit }
        set { cache.countLimit = newValue }
    }
    
    var totalCostLimit: Int {
        get { cache.totalCostLimit }
        set { cache.totalCostLimit = newValue }
    }
    
    func value(forKey key: Key) -> Value? {
        return cache.object(forKey: key as NSObject) as? Value
    }
    
    
    
}
