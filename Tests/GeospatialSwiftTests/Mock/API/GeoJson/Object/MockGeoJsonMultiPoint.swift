@testable import GeospatialSwift

final class MockGeoJsonMultiPoint: MockGeoJsonCoordinatesGeometry, GeoJsonMultiPoint {
    func invalidReasons(tolerance: Double) -> [MultipointInvalidReason] {
        return []
    }
}
