import Foundation

struct SearchResult: Codable {
    let icons: [String]
    let total: Int
    let collections: [String: CollectionInfo]
}

struct CollectionInfo: Codable {
    let name: String
}
