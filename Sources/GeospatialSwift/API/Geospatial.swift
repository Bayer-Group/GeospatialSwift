/**
 A framework to parse GeoJson and create GeoJson by means of a GeoJsonObject.
 
 The GeoJson object has many helper methods including boundingBox, which eliminates the need to add a bbox parameter on the geoJson.
 */
open class Geospatial {
    /**
     Everything GeoJson. The base of all other functionality.
     */
    public let geoJson: GeoJson
    
    /**
     Everything Geohash
     */
    public let geohash: GeohashCoder
    
    /**
     Everything Geospatial Calculation
     */
    public let calculator: GeodesicCalculator
    
    internal let wktParser: WktParser
    
    /**
     Initialize the interface using a configuration to describe how the interface should react to requests.
     */
    public init() {
        geoJson = GeoJson()
        
        geohash = GeohashCoder()
        
        calculator = Calculator
        
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
