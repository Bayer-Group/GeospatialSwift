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
    }
}
