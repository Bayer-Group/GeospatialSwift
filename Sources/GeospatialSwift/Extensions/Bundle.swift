import Foundation

private class BundleClass {}

internal extension Bundle {
    static var source: Bundle { return Bundle(for: BundleClass.self) }
    
    static var sourceVersion: String { return source.infoDictionary?["CFBundleShortVersionString"] as? String ?? "" }
}
