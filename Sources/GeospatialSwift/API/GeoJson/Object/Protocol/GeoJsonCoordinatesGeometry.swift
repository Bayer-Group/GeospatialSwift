/**
 A Geometry Object which has Geo Json coordinates. Includes all of type GeoJsonGeometry except GeoJsonGeometryCollection.
 */
public protocol GeoJsonCoordinatesGeometry: GeoJsonGeometry {
    var geoJsonCoordinates: [Any] { get }
    
    var geometries: [GeoJsonGeometry] { get }
    
    var boundingBox: GeodesicBoundingBox { get }
    
    func distance(to point: GeodesicPoint, tolerance: Double) -> Double
    
    var points: [GeodesicPoint] { get }
    
    func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation]
}

public extension GeoJsonCoordinatesGeometry {
    var objectGeometries: [GeoJsonGeometry]? { return geometries }
    
    var objectBoundingBox: GeodesicBoundingBox? { return boundingBox }
    
    var geoJson: GeoJsonDictionary { return ["type": type.name, "coordinates": geoJsonCoordinates] }
    
    var geometries: [GeoJsonGeometry] { return [self] }
    
    func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? { return distance(to: point, tolerance: tolerance) }
    
    func distance(to point: GeodesicPoint) -> Double { return distance(to: point, tolerance: 0) }
}

public struct GeoJsonSimpleViolation {
    public let problems: [GeoJsonCoordinatesGeometry]
    public let reason: GeoJsonSimpleViolationReason
    //    case multipointSimpleViolations(_: [MultipointSimpleViolation])
    //    case lineStringSimpleViolations(_: [LineStringSimpleViolation])
    //    case multiLineStringSimpleViolations(_: [MultiLineStringSimpleViolation])
    //    case polygonSimpleViolations(_: [PolygonSimpleViolation])
    //    case multiPolygonSimpleViolations(_: [MultiPolygonSimpleViolation])
}

public enum GeoJsonSimpleViolationReason {
    case selfIntersection
    case duplicate
    #warning("TODO")
}

//public enum GeoJsonInvalidGeometry {
//    case multiPointInvalidGeometry(_: [GeoJsonPoint])
//    case lineStringInvalidGeometry(_: [[GeoJsonPoint]])
//    case multiLineStringInvalidGeometry(_: [[GeoJsonPoint]])
//    case polygonInvalidGeometry(_: [GeoJsonLineString])
//    case multiPolygonInvalidGeometry(_: [GeoJsonLineString])
//}

public extension GeoJsonCoordinatesGeometry {
    // swiftlint:disable:next cyclomatic_complexity
    //    public func allSimpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
    ////        guard let objectGeometries = objectGeometries else { return [] }
    ////
    ////        let simpleViolations = objectGeometries.compactMap { object -> [GeoJsonSimpleViolation] in
    ////            switch object {
    ////            case _ as GeoJsonPoint:
    ////                return []
    ////            case let object as GeoJsonMultiPoint:
    ////                return object.simpleViolations(tolerance: tolerance)
    ////            case let object as GeoJsonLineString:
    ////                return [.lineStringSimpleViolations(object.simpleViolations(tolerance: tolerance))]
    ////            case let object as GeoJsonMultiLineString:
    ////                return [.multiLineStringSimpleViolations(object.simpleViolations(tolerance: tolerance))]
    ////            case let object as GeoJsonPolygon:
    ////                return [.polygonSimpleViolations(object.simpleViolations(tolerance: tolerance))]
    ////            case let object as GeoJsonMultiPolygon:
    ////                return [.multiPolygonSimpleViolations(object.simpleViolations(tolerance: tolerance))]
    ////            case let object as GeoJsonGeometryCollection:
    ////                return object.simpleViolations(tolerance: tolerance)
    ////
    ////        }
    //
    //        return simpleViolations.flatMap { $0 }
    //    }
//    
//    public func invalidObject(tolerance: Double) -> [GeoJsonInvalidGeometry] {
//        guard let objectGeometries = objectGeometries else { return [] }
//        let reasons = objectGeometries.map { $0.simpleViolations(tolerance: tolerance) }
//        
//        switch objectGeometries[0] {
//        case _ as GeoJsonMultiPoint: return objectGeometries.flatMap { $0.invalidObjectForMultiPoint(simpleViolations: reasons) }
//        case _ as GeoJsonLineString: return objectGeometries.flatMap { $0.invalidObjectForLineString(simpleViolations: reasons) }
//        case _ as GeoJsonMultiLineString: return objectGeometries.flatMap { $0.invalidObjectForMultiLineString(simpleViolations: reasons, tolerance: tolerance) }
//        default: return []
//        }
//    }
//    
//    private func invalidObjectForMultiPoint(simpleViolations: [[GeoJsonSimpleViolation]]) -> [GeoJsonInvalidGeometry] {
//        guard let objectGeometries = objectGeometries else { return [] }
//        
//        var invalidPointGeoJson = [GeoJsonPoint]()
//        
//        simpleViolations.enumerated().forEach { index, reason in
//            if case GeoJsonSimpleViolation.multipointSimpleViolations(let multiPointSimpleViolations) = reason[0], !multiPointSimpleViolations.isEmpty {
//                multiPointSimpleViolations.forEach {
//                    if case MultipointSimpleViolation.duplicates(indices: let indices) = $0 {
//                        indices.forEach {
//                            if let duplicatePoint = objectGeometries[$0] as? GeoJsonPoint {
//                                invalidPointGeoJson.append(duplicatePoint)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        
//        return [GeoJsonInvalidGeometry.multiPointInvalidGeometry(invalidPointGeoJson)]
//    }
//    
//    private func invalidObjectForLineString(simpleViolations: [[GeoJsonSimpleViolation]]) -> [GeoJsonInvalidGeometry] {
//        guard let objectGeometries = objectGeometries else { return [] }
//        
//        var invalidLineStringGeoJson = [[GeoJsonPoint]]()
//        simpleViolations.enumerated().forEach { index, reason in
//            if case GeoJsonSimpleViolation.lineStringSimpleViolations(let lineStringSimpleViolations) = reason[0], !lineStringSimpleViolations.isEmpty {
//                lineStringSimpleViolations.forEach {
//                    if case LineStringSimpleViolation.duplicates(indices: let pointIndices) = $0 {
//                        pointIndices.forEach {
//                            if let duplicatePoint = objectGeometries[$0] as? GeoJsonPoint {
//                                invalidLineStringGeoJson.append([duplicatePoint])
//                            }
//                        }
//                    }
//                    if case LineStringSimpleViolation.selfIntersects(segmentIndices: let segmentIndices) = $0 {
//                        segmentIndices.forEach { index, otherIndices in
//                            if let lineString = objectGeometries[0] as? GeoJsonLineString {
//                                invalidLineStringGeoJson.append([lineString.geoJsonPoints[index], lineString.geoJsonPoints[index + 1]])
//                            }
//                            otherIndices.forEach {
//                                if let lineString = objectGeometries[0] as? GeoJsonLineString {
//                                    invalidLineStringGeoJson.append([lineString.geoJsonPoints[$0], lineString.geoJsonPoints[$0 + 1]])
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        return [GeoJsonInvalidGeometry.lineStringInvalidGeometry(invalidLineStringGeoJson)]
//    }
//    
//    private func invalidObjectForMultiLineString(simpleViolations: [[GeoJsonSimpleViolation]], tolerance: Double) -> [GeoJsonInvalidGeometry] {
//        guard let objectGeometries = objectGeometries else { return [] }
//        
//        var invalidMultiLineStringGeoJson = [[GeoJsonPoint]]()
//        var invalidLineString = [GeoJsonInvalidGeometry]()
//        
//        simpleViolations.enumerated().forEach { index, reason in
//            if case GeoJsonSimpleViolation.multiLineStringSimpleViolations(let multiLineStringSimpleViolations) = reason[0], !multiLineStringSimpleViolations.isEmpty {
//                
//                multiLineStringSimpleViolations.forEach {
//                    if case MultiLineStringSimpleViolation.lineStringInvalid(reasonByIndex: let indices) = $0 {
//                        let xxx = indices.map { GeoJsonSimpleViolation.lineStringSimpleViolations($0.value) }
//                        invalidLineString.append(contentsOf: invalidObjectForLineString(simpleViolations: [xxx]))
//                    }
//                    if case MultiLineStringSimpleViolation.lineStringsIntersect(intersection: let intersection) = $0 {
//                        if let lineIntersect = objectGeometries[index] as? GeoJsonMultiLineString {
//                            intersection.forEach {
//                                let firstSegmentIndexPath = $0.firstSegmentIndexPath
//                                var point1 = lineIntersect.lineStrings[firstSegmentIndexPath.lineStringIndex].geoJsonPoints[firstSegmentIndexPath.segmentIndex]
//                                var point2 = lineIntersect.lineStrings[firstSegmentIndexPath.lineStringIndex].geoJsonPoints[firstSegmentIndexPath.segmentIndex + 1]
//                                invalidMultiLineStringGeoJson.append([point1, point2])
//                                
//                                $0.secondSegmentIndexPath.forEach {
//                                    point1 = lineIntersect.lineStrings[$0.lineStringIndex].geoJsonPoints[$0.segmentIndex]
//                                    point2 = lineIntersect.lineStrings[$0.lineStringIndex].geoJsonPoints[$0.segmentIndex + 1]
//                                    invalidMultiLineStringGeoJson.append([point1, point2])
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        return [GeoJsonInvalidGeometry.multiLineStringInvalidGeometry(invalidMultiLineStringGeoJson)] + invalidLineString
//    }
//    
}
