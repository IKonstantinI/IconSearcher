import Foundation

struct IconDetailResponse: Codable {
    let prefix: String
    let width: Int
    let height: Int
    let icons: [String: IconMetadata]
}

struct IconMetadata: Codable {
    let tags: [String]?
    let body: String
}
