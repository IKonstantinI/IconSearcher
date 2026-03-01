import Foundation

struct Icon {
    let fullName: String
    
    var tags: [String] = []
    var width: Int = 0
    var height: Int = 0
    
    var collectionPrefix: String {
        (fullName.split(separator: ":").first).map(String.init) ?? ""
    }
    var iconName: String {
        (fullName.split(separator: ":").last).map(String.init) ?? ""
    }
}
