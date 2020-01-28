import Foundation

private class BundleClass {}

internal extension Bundle {
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    static var source: Bundle { Bundle(for: BundleClass.self) }
    
    static var sourceVersion: String { source.infoDictionary?["CFBundleShortVersionString"] as? String ?? "" }
    #else
    static var sourceVersion: String { "0.2.0" }
    #endif
}
