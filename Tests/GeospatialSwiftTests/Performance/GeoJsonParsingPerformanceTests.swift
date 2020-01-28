import XCTest

@testable import GeospatialSwift

final class GeoJsonParsingPerformanceTest: XCTestCase {
    
    func testPolygonBoundingBox() {
        let geospatial = Geospatial()
        
        let geoJsons = MockData.geoJsonTestData.compactMap { $0["geoJson"] as? GeoJsonDictionary }
        
        var cacheForMemoryUsageInfo = [GeoJsonObject]()
        
        measure {
            for _ in 0..<50 {
                for geoJson in geoJsons {
                    cacheForMemoryUsageInfo.append(geospatial.geoJson.parseObject(fromValidatedGeoJson: geoJson))
                }
            }
        }
    }
    
}
