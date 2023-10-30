
import Foundation

public enum GEOSObjectType: Hashable, Sendable {
    case point
    case lineString
    case linearRing
    case polygon
    case multiPoint
    case multiLineString
    case multiPolygon
    case geometryCollection
}
