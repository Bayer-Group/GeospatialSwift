@testable import GeospatialSwift

class MockGeoJsonBoundingBox: GeodesicBoundingBox {
    var description: String = ""
    
    private(set) var minLongitudeCallCount = 0
    var minLongitude: Double {
        minLongitudeCallCount += 1
        
        return boundingCoordinatesResult.minLongitude
    }
    
    private(set) var minLatitudeCallCount = 0
    var minLatitude: Double {
        minLatitudeCallCount += 1
        
        return boundingCoordinatesResult.minLatitude
    }
    
    private(set) var maxLongitudeCallCount = 0
    var maxLongitude: Double {
        maxLongitudeCallCount += 1
        
        return boundingCoordinatesResult.maxLongitude
    }
    
    private(set) var maxLatitudeCallCount = 0
    var maxLatitude: Double {
        maxLatitudeCallCount += 1
        
        return boundingCoordinatesResult.maxLatitude
    }
    
    private(set) var longitudeDeltaCallCount = 0
    var longitudeDeltaResult: Double = 0
    var longitudeDelta: Double {
        longitudeDeltaCallCount += 1
        
        return longitudeDeltaResult
    }
    
    private(set) var latitudeDeltaCallCount = 0
    var latitudeDeltaResult: Double = 0
    var latitudeDelta: Double {
        latitudeDeltaCallCount += 1
        
        return latitudeDeltaResult
    }
    
    private(set) var polygonCallCount = 0
    lazy var polygonResult: GeoJsonPolygon = MockGeoJsonPolygon()
    var polygon: GeoJsonPolygon {
        polygonCallCount += 1
        
        return polygonResult
    }
    
    private(set) var pointsCallCount = 0
    var pointsResult: [GeoJsonPoint] = []
    var points: [GeodesicPoint] {
        pointsCallCount += 1
        
        return pointsResult
    }
    
    private(set) var centroidCallCount = 0
    lazy var centroidResult: GeoJsonPoint = MockGeoJsonPoint()
    var centroid: GeodesicPoint {
        centroidCallCount += 1
        
        return centroidResult
    }
    
    private(set) var bestCallCount = 0
    lazy var bestResult: GeodesicBoundingBox = MockGeoJsonBoundingBox()
    func best(_ boundingBoxes: [GeodesicBoundingBox]) -> GeodesicBoundingBox {
        bestCallCount += 1
        
        return bestResult
    }
    
    private(set) var adjustedCallCount = 0
    lazy var adjustedResult: GeodesicBoundingBox = MockGeoJsonBoundingBox()
    func adjusted(minimumAdjustment: Double) -> GeodesicBoundingBox {
        adjustedCallCount += 1
        
        return adjustedResult
    }
    
    private(set) var containsCallCount = 0
    var containsResult: Bool = false
    func contains(point: GeodesicPoint) -> Bool {
        containsCallCount += 1
        
        return containsResult
    }
    
    private(set) var overlapsCallCount = 0
    var overlapsResult: Bool = false
    func overlaps(boundingBox: GeodesicBoundingBox) -> Bool {
        overlapsCallCount += 1
        
        return overlapsResult
    }
    
    private(set) var boundingCoordinatesCallCount = 0
    var boundingCoordinatesResult: BoundingCoordinates = (0, 0, 0, 0)
    var boundingCoordinates: BoundingCoordinates {
        boundingCoordinatesCallCount += 1
        
        return boundingCoordinatesResult
    }
}
