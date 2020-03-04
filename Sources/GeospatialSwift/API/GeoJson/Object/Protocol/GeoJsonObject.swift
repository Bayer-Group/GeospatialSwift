import Foundation

/**
 GeoJsonObject Protocol
 
 Does not support projected coordinates, only geographic
 */
public protocol GeoJsonObject {
    // SOMEDAY: does not yet handle optional "bbox" or "crs" members
    
    var type: GeoJsonObjectType { get }
    
    var objectGeometries: [GeoJsonGeometry] { get }
    
    var objectBoundingBox: GeodesicBoundingBox? { get }
    
    var geoJson: GeoJsonDictionary { get }
    
    func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double?
    
    func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool
    
    func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation]
    
    // SOMEDAY: More fun!
    //func overlaps(geoJsonObject: GeoJsonObject, tolerance: Double) -> Bool
}

extension GeoJsonObject {
    public func contains(_ point: GeodesicPoint) -> Bool { contains(point, tolerance: 0) }
    
    public func objectDistance(to point: GeodesicPoint) -> Double? { objectDistance(to: point, tolerance: 0) }
}

extension GeoJsonObject {
    public var isSimpleGeometry: Bool { [.point, .lineString, .polygon].contains(type) }
    
    // Trust geoJson serialization
    // swiftlint:disable:next force_try
    public var geoJsonData: Data { try! JSONSerialization.data(withJSONObject: geoJson, options: []) }
    
    // Trust geoJson encoding
    public var geoJsonString: String { String(data: geoJsonData, encoding: .utf8)! }
    
    public var coordinatesGeometries: [GeoJsonCoordinatesGeometry] {
        objectGeometries.flatMap { objectGeometry -> [GeoJsonCoordinatesGeometry] in
            if let geometry = objectGeometry as? GeoJsonCoordinatesGeometry { return [geometry] }
            
            return objectGeometry.coordinatesGeometries
        }
    }
    
    public var linearGeometries: [GeoJsonLinearGeometry] {
        objectGeometries.flatMap { objectGeometry -> [GeoJsonLinearGeometry] in
            if let geometry = objectGeometry as? GeoJsonLinearGeometry { return [geometry] }
            
            if objectGeometry is GeoJsonCoordinatesGeometry { return [] }
            
            return objectGeometry.linearGeometries
        }
    }
    
    public var closedGeometries: [GeoJsonClosedGeometry] {
        objectGeometries.flatMap { objectGeometry -> [GeoJsonClosedGeometry] in
            if let geometry = objectGeometry as? GeoJsonClosedGeometry { return [geometry] }
            
            if objectGeometry is GeoJsonCoordinatesGeometry { return [] }
            
            return objectGeometry.closedGeometries
        }
    }
}

// swiftlint:disable:next cyclomatic_complexity
public func == (lhs: GeoJsonObject?, rhs: GeoJsonObject?) -> Bool {
    guard lhs != nil || rhs != nil else { return type(of: lhs) == type(of: rhs) }
    
    guard lhs?.type == rhs?.type, let type = lhs?.type ?? rhs?.type else { return false }
    
    switch type {
    case .featureCollection:
        guard let lhs = lhs as? GeoJson.FeatureCollection, let rhs = rhs as? GeoJson.FeatureCollection, lhs.features.count == rhs.features.count else { return false }
        
        for feature in lhs.features where !rhs.features.contains { $0 == feature } { return false }
        
        return true
    case .feature:
        guard let lhs = lhs as? GeoJson.Feature, let rhs = rhs as? GeoJson.Feature else { return false }
        
        return lhs.geometry == rhs.geometry && lhs.idAsString == rhs.idAsString && lhs.properties == rhs.properties
    case .geometryCollection:
        guard let lhs = lhs as? GeoJson.GeometryCollection, let rhs = rhs as? GeoJson.GeometryCollection else { return false }
        
        guard lhs.objectGeometries.count == rhs.objectGeometries.count else { return false }
        
        for geometry in lhs.objectGeometries where !rhs.objectGeometries.contains { $0 == geometry } { return false }
        
        return true
    case .multiPolygon:
        guard let lhs = lhs as? GeoJson.MultiPolygon, let rhs = rhs as? GeoJson.MultiPolygon, lhs.polygons.count == rhs.polygons.count else { return false }
        
        for polygon in lhs.polygons where !rhs.polygons.contains { $0 == polygon } { return false }
        
        return true
    case .polygon:
        guard let lhs = lhs as? GeodesicPolygon, let rhs = rhs as? GeodesicPolygon else { return false }
        
        return lhs == rhs
    case .multiLineString:
        guard let lhs = lhs as? GeoJson.MultiLineString, let rhs = rhs as? GeoJson.MultiLineString, lhs.lines.count == rhs.lines.count else { return false }
        
        for line in lhs.lines where !rhs.lines.contains { $0 == line } { return false }
        
        return true
    case .lineString:
        guard let lhs = lhs as? GeodesicLine, let rhs = rhs as? GeodesicLine else { return false }
        
        return lhs == rhs
    case .multiPoint:
        guard let lhs = lhs as? GeoJson.MultiPoint, let rhs = rhs as? GeoJson.MultiPoint, lhs.points.count == rhs.points.count else { return false }
        
        for point in lhs.points where !rhs.points.contains { $0 == point } { return false }
        
        return true
    case .point:
        guard let lhs = lhs as? GeodesicPoint, let rhs = rhs as? GeodesicPoint else { return false }
        
        return lhs == rhs
    }
}

public func == (lhs: [GeoJsonObject]?, rhs: [GeoJsonObject]?) -> Bool {
    guard lhs != nil || rhs != nil else { return true }
    
    guard let lhs = lhs, let rhs = rhs, lhs.count == rhs.count else { return false }
    
    for geoJsonObject in lhs where !rhs.contains { $0 == geoJsonObject } { return false }
    
    return true
}
