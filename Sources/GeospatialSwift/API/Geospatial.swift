/**
 A protocol provided for unit testing.
 */
public protocol GeospatialProtocol: class {
    var geoJson: GeoJsonProtocol { get }
    var geohash: GeohashCoderProtocol { get }
    
    var calculator: GeodesicCalculatorProtocol { get }
    
    func parse(wkt: String) -> GeoJsonObject?
}

/**
 A framework to parse GeoJson and create GeoJson by means of a GeoJsonObject.
 
 The GeoJson object has many helper methods including boundingBox, which eliminates the need to add a bbox parameter on the geoJson.
 */
open class Geospatial: GeospatialProtocol {
    /**
     Everything GeoJson. The base of all other functionality.
     */
    public let geoJson: GeoJsonProtocol
    
    /**
     Everything Geohash
     */
    public let geohash: GeohashCoderProtocol
    
    /**
     Everything Geospatial Calculation
     */
    public let calculator: GeodesicCalculatorProtocol
    
    internal let wktParser: WktParserProtocol
    
    /**
     Initialize the interface using a configuration to describe how the interface should react to requests.
     */
    public init() {
        geoJson = GeoJson()
        
        geohash = GeohashCoder()
        
        calculator = GeodesicCalculator.shared
        
        wktParser = WktParser(geoJson: geoJson)
    }
    
    /**
     Parses a WKT String. Not all formats are currently supported.
     
     - wkt: a String which conforms to a specific WKT format.
     
     - returns: A successfully parsed GeoJsonObject or nil if the specification was not correct
     
     Experimental, untested, not fully written, and no plans to fully support in the future.
     */
    public func parse(wkt: String) -> GeoJsonObject? { wktParser.geoJsonObject(from: wkt) }
}
