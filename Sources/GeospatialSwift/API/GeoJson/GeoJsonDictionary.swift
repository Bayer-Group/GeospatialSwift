import Foundation

public typealias GeoJsonDictionary = [String: Any]

internal func == (lhs: GeoJsonDictionary?, rhs: GeoJsonDictionary?) -> Bool {
    guard lhs != nil || rhs != nil else { return true }
    
    return NSDictionary(dictionary: lhs ?? [:]).isEqual(to: rhs ?? [:])
}
