import Foundation

enum API {
    enum Freepik {
        static let scheme = "https"
        static let host = "api.freepik.com"
        static let path = "/v1/icons"
        static let apiKeyHeader = "x-freepik-api-key"
        
        static var components: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
    }
}
