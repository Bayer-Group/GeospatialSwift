extension GeoJson {
    internal struct LinearRing {
        internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
            guard let pointsCoordinatesJson = coordinatesJson as? [[Double]] else { return .init(reason: "A valid LinearRing must have valid coordinates") }
            
            guard pointsCoordinatesJson.first! == pointsCoordinatesJson.last! else { return .init(reason: "A valid LinearRing must have the first and last points equal") }
            
            guard pointsCoordinatesJson.count >= 4 else { return .init(reason: "A valid LinearRing must have at least 4 points") }
            
            let validatePoints = pointsCoordinatesJson.reduce(nil) { $0 + Point.validate(coordinatesJson: $1) }
            
            return validatePoints.flatMap { .init(reason: "Invalid Point in LinearRing") + $0 }
        }
        
        internal static func validate(linearRing: LineString) -> InvalidGeoJson? {
            guard linearRing.points.first! == linearRing.points.last! else { return .init(reason: "A valid LinearRing must have the first and last points equal") }
            
            guard linearRing.points.count >= 4 else { return .init(reason: "A valid LinearRing must have at least 4 points")}
            
            return nil
        }
        
        internal static func simpleViolations(linearRing: LineString, tolerance: Double) -> [GeoJsonSimpleViolation] {
            let duplicatePoints = Calculator.simpleViolationDuplicateIndices(points: linearRing.points.dropLast(), tolerance: tolerance).map { linearRing.geoJsonPoints[$0[0]] }
            
            guard duplicatePoints.isEmpty else { return [GeoJsonSimpleViolation(problems: duplicatePoints, reason: .pointDuplication)] }
            
            let selfIntersectsIndices = Calculator.simpleViolationSelfIntersectionIndices(line: linearRing, tolerance: tolerance)
            
            guard selfIntersectsIndices.isEmpty else {
                var simpleViolationGeometries = [GeoJsonCoordinatesGeometry]()
                selfIntersectsIndices.forEach { firstIndex, secondIndices in
                    var point = GeoJson.Point(longitude: linearRing.segments[firstIndex].startPoint.longitude, latitude: linearRing.segments[firstIndex].startPoint.latitude)
                    var otherPoint = GeoJson.Point(longitude: linearRing.segments[firstIndex].endPoint.longitude, latitude: linearRing.segments[firstIndex].endPoint.latitude)
                    simpleViolationGeometries.append(point)
                    simpleViolationGeometries.append(otherPoint)
                    simpleViolationGeometries.append(GeoJson.LineString(points: [point, otherPoint]))
                    
                    secondIndices.forEach {
                        point = GeoJson.Point(longitude: linearRing.segments[$0].startPoint.longitude, latitude: linearRing.segments[$0].startPoint.latitude)
                        otherPoint = GeoJson.Point(longitude: linearRing.segments[$0].endPoint.longitude, latitude: linearRing.segments[$0].endPoint.latitude)
                        simpleViolationGeometries.append(point)
                        simpleViolationGeometries.append(otherPoint)
                        simpleViolationGeometries.append(GeoJson.LineString(points: [point, otherPoint]))
                    }
                }
                
                return [GeoJsonSimpleViolation(problems: simpleViolationGeometries, reason: .lineIntersection)]
            }
            
            return []
        }
    }
}
