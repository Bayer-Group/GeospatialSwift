@testable import GeospatialSwift

final class MockGeoJsonPolygon: MockGeoJsonClosedGeometry, GeoJsonPolygon {
    var geoJsonLinearRings: [GeoJsonLineString] { return [geoJsonMainRing] + geoJsonNegativeRings }
    var geoJsonMainRing: GeoJsonLineString = MockData.lineStrings.first!
    var geoJsonNegativeRings: [GeoJsonLineString] = []
    
    var mainRing: GeodesicLine { return geoJsonMainRing }
    var negativeRings: [GeodesicLine] { return geoJsonNegativeRings }
    
    override init() {
        super.init()
        
        geoJsonObjectTypeResult = .polygon
    }
    
    func simpleViolations(tolerance: Double) -> [PolygonSimpleViolation] {
        return []
    }
    
    private(set) var linearRingsCallCount: Int = 0
    var linearRingsResult: [GeodesicLine] { return geoJsonLinearRings }
    var linearRings: [GeodesicLine] {
        linearRingsCallCount += 1
        
        return linearRingsResult
    }
    
    private(set) var centroidCallCount = 0
    var centroidResult: GeoJsonPoint = MockGeoJsonPoint()
    var centroid: GeodesicPoint {
        centroidCallCount += 1
        
        return centroidResult
    }
}
