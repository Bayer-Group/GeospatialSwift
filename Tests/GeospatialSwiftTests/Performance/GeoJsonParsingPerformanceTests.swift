import XCTest

@testable import GeospatialSwift

final class GeoJsonParsingPerformanceTest: XCTestCase {
    
    func testPolygonBoundingBox() {
        let geospatial = Geospatial()
        
        #if swift(>=4.1)
        let geoJsons = MockData.geoJsonTestData.compactMap { $0["geoJson"] as? GeoJsonDictionary }
        #else
        let geoJsons = MockData.geoJsonTestData.flatMap { $0["geoJson"] as? GeoJsonDictionary }
        #endif
        
        var cacheForMemoryUsageInfo = [GeoJsonObject]()
        
        measure {
            for _ in 0..<50 {
                for geoJson in geoJsons {
                    cacheForMemoryUsageInfo.append(geospatial.geoJson.parse(geoJson: geoJson)!)
                }
            }
        }
    }
    
}
