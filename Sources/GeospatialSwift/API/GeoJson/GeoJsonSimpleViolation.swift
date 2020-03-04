public struct GeoJsonSimpleViolation {
    public let problems: [GeoJsonCoordinatesGeometry]
    public let reason: GeoJsonSimpleViolationReason
}

public enum GeoJsonSimpleViolationReason {
    case lineIntersection
    case multiLineIntersection
    case pointDuplication
    case polygonHoleOutside
    case polygonNegativeRingContained
    case polygonSelfIntersection
    case polygonMultipleVertexIntersection
    case multiPolygonContained
    case multiPolygonIntersection
}
