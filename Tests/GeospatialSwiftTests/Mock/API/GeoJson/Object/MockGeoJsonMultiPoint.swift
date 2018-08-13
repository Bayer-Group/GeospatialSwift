@testable import GeospatialSwift

final class MockGeoJsonMultiPoint: MockGeoJsonCoordinatesGeometry, GeoJsonMultiPoint {
    var geoJsonPoints: [GeoJsonPoint] = []
    
    func invalidReasons(tolerance: Double) -> [MultipointInvalidReason] {
        return []
    }
}
