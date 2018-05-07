@testable import GeospatialSwift

class MockGeoJsonBoundingBox: GeoJsonBoundingBox {
    private(set) var minLongitudeCallCount = 0
    private(set) var minLatitudeCallCount = 0
    private(set) var maxLongitudeCallCount = 0
    private(set) var maxLatitudeCallCount = 0
    private(set) var longitudeDeltaCallCount = 0
    private(set) var latitudeDeltaCallCount = 0
    private(set) var polygonCallCount = 0
    private(set) var pointsCallCount = 0
    private(set) var centroidCallCount = 0
    private(set) var bestCallCount = 0
    private(set) var adjustedCallCount = 0
    private(set) var containsCallCount = 0
    private(set) var overlapsCallCount = 0
    private(set) var boundingCoordinatesCallCount = 0
    
    var longitudeDeltaResult: Double = 0
    var latitudeDeltaResult: Double = 0
    lazy var polygonResult: GeoJsonPolygon = MockGeoJsonPolygon()
    var pointsResult: [GeoJsonPoint] = []
    lazy var centroidResult: GeoJsonPoint = MockGeoJsonPoint()
    lazy var bestResult: GeoJsonBoundingBox = MockGeoJsonBoundingBox()
    lazy var adjustedResult: GeoJsonBoundingBox = MockGeoJsonBoundingBox()
    var containsResult: Bool = false
    var overlapsResult: Bool = false
    var boundingCoordinatesResult: BoundingCoordinates = (0, 0, 0, 0)
    
    var description: String = ""
    
    var minLongitude: Double {
        minLongitudeCallCount += 1
        
        return boundingCoordinatesResult.minLongitude
    }
    
    var minLatitude: Double {
        minLatitudeCallCount += 1
        
        return boundingCoordinatesResult.minLatitude
    }
    
    var maxLongitude: Double {
        maxLongitudeCallCount += 1
        
        return boundingCoordinatesResult.maxLongitude
    }
    
    var maxLatitude: Double {
        maxLatitudeCallCount += 1
        
        return boundingCoordinatesResult.maxLatitude
    }
    
    var longitudeDelta: Double {
        longitudeDeltaCallCount += 1
        
        return longitudeDeltaResult
    }
    
    var latitudeDelta: Double {
        latitudeDeltaCallCount += 1
        
        return latitudeDeltaResult
    }
    
    var polygon: GeoJsonPolygon {
        polygonCallCount += 1
        
        return polygonResult
    }
    
    var points: [GeodesicPoint] {
        pointsCallCount += 1
        
        return pointsResult
    }
    
    var centroid: GeodesicPoint {
        centroidCallCount += 1
        
        return centroidResult
    }
    
    func best(_ boundingBoxes: [GeoJsonBoundingBox]) -> GeoJsonBoundingBox {
        bestCallCount += 1
        
        return bestResult
    }
    
    func adjusted(minimumAdjustment: Double) -> GeoJsonBoundingBox {
        adjustedCallCount += 1
        
        return adjustedResult
    }
    
    func contains(point: GeodesicPoint) -> Bool {
        containsCallCount += 1
        
        return containsResult
    }
    
    func overlaps(boundingBox: GeoJsonBoundingBox) -> Bool {
        overlapsCallCount += 1
        
        return overlapsResult
    }
    
    var boundingCoordinates: BoundingCoordinates {
        boundingCoordinatesCallCount += 1
        
        return boundingCoordinatesResult
    }
}
