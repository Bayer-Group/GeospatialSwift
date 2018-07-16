public protocol GeoJsonPolygon: GeoJsonSimpleGeometry, GeoJsonClosedGeometry {
    var linearRings: [GeoJsonLineString] { get }
    
    var centroid: GeodesicPoint { get }
    
    // SOMEDAY: PolygonValidation: hasIntersection, conflictingIndices, ringsOverlap, hasBowtie, maybe an enum array of validation issues
}

extension GeoJson {
    /**
     Creates a GeoJsonPolygon
     */
    public func polygon(linearRings: [GeoJsonLineString]) -> GeoJsonPolygon? {
        return Polygon(linearRings: linearRings)
    }
    
    public struct Polygon: GeoJsonPolygon {
        public let type: GeoJsonObjectType = .polygon
        public var geoJsonCoordinates: [Any] { return linearRings.map { $0.geoJsonCoordinates } }
        
        public var description: String {
            return """
            Polygon: \(
            """
            (\n\(linearRings.enumerated().map { "\($0 == 0 ? "Main Ring" : "Negative Ring \($0)") - \($1)" }.joined(separator: ",\n"))
            """
            .replacingOccurrences(of: "\n", with: "\n\t")
            )\n)
            """
        }
        
        public let linearRings: [GeoJsonLineString]
        
        public var points: [GeoJsonPoint] { return linearRings.flatMap { $0.points } }
        
        public var boundingBox: GeodesicBoundingBox { return BoundingBox.best(linearRings.map { $0.boundingBox })! }
        
        public var centroid: GeodesicPoint { return Calculator.centroid(polygon: self) }
        
        public var hasHole: Bool { return linearRings.count > 1 }
        
        public var area: Double { return Calculator.area(polygon: self) }
        
        internal init?(coordinatesJson: [Any]) {
            guard let linearRingsJson = coordinatesJson as? [[Any]] else { Log.warning("A valid Polygon must have valid coordinates"); return nil }
            
            var linearRings = [GeoJsonLineString]()
            for linearRingJson in linearRingsJson {
                if let linearRing = LineString(coordinatesJson: linearRingJson) {
                    linearRings.append(linearRing)
                } else {
                    Log.warning("Invalid linear ring (LineString) in Polygon"); return nil
                }
            }
            
            self.init(linearRings: linearRings)
        }
        
        // SOMEDAY: See this helpful link for validations: https://github.com/mapbox/mapnik-vector-tile/issues/153
        // SOMEDAY: More strict additions:
        
        // SOMEDAY: Check for validity beyond geoJson specification of geometries - Perhaps this will set an isValid flag or an invalidReasonEnum on the GeoJsonObject itself rather than failing.
        
        //Checking winding order is valid
        //Checking geometry is_valid
        //Checking geometry is_simple
        //Triangle that reprojection to tile coordinates will cause winding order reversed
        //Polygon that will be reprojected into tile coordinates as a line
        //Polygon with "spike"
        //Polygon with hole that has a "spike"
        //Polygon with large number of points repeated
        //Polygon where area threshold removes geometry AFTER clipping
        //Bowtie Polygon where two points touch
        
        // Polygon with reversed winding order
        // Polygon with hole where hole has invalid winding order
        //    o  A linear ring MUST follow the right-hand rule with respect to the
        //    area it bounds, i.e., exterior rings are counterclockwise, and
        //    holes are clockwise.
        // SOMEDAY: Can run contains on all interior polygon points to be contained in the exterior polygon and NOT contains in other interior polygons.
        // Polygon where hole intersects with same point as exterior edge point
        // Polygon where hole extends past edge of polygon
        //    o  For Polygons with more than one of these rings, the first MUST be
        //    the exterior ring, and any others MUST be interior rings.  The
        //    exterior ring bounds the surface, and the interior rings (if
        //    present) bound holes within the surface.
        fileprivate init?(linearRings: [GeoJsonLineString]) {
            guard linearRings.count >= 1 else { Log.warning("A valid Polygon must have at least one LinearRing"); return nil }
            
            for linearRing in linearRings {
                guard linearRing.points.first! == linearRing.points.last! else { Log.warning("A valid Polygon LinearRing must have the first and last points equal"); return nil }
                
                guard linearRing.points.count >= 4 else { Log.warning("A valid Polygon LinearRing must have at least 4 points"); return nil }
            }
            
            self.linearRings = linearRings
        }
        
        public func edgeDistance(to point: GeodesicPoint, errorDistance: Double) -> Double {
            return linearRings.map { $0.distance(to: point, errorDistance: errorDistance) }.min()!
        }
        
        public func distance(to point: GeodesicPoint, errorDistance: Double) -> Double {
            if contains(point, errorDistance: errorDistance) { return 0 }
            
            return edgeDistance(to: point, errorDistance: errorDistance)
        }
        
        public func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool {
            let contains = Calculator.contains(point: point, polygon: self)
            
            if errorDistance < 0 && contains { return edgeDistance(to: point, errorDistance: 0) >= -errorDistance }
            
            if errorDistance > 0 { return contains || edgeDistance(to: point, errorDistance: 0) <= errorDistance }
            
            return contains
        }
    }
}
