@testable import GeospatialSwift

final class MockGeoJsonFeatureCollection: MockGeoJsonGeometry, GeoJsonFeatureCollection {
    private(set) var featuresCallCount = 0
    var featuresResult: [GeoJsonFeature] = []
    var features: [GeoJsonFeature] {
        featuresCallCount += 1
        
        return featuresResult
    }
}
