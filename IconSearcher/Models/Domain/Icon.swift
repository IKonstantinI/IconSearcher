import Foundation

struct Icon: Codable {
    let name: String
    let tags: [String]
    let url: URL
    let width: Int
    let height: Int
}
