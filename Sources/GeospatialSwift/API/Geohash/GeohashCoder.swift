public protocol GeohashCoderProtocol {
    func geohash(for point: GeodesicPoint, precision: Int) -> String
    func geohashBox(for point: GeodesicPoint, precision: Int) -> GeoJsonGeohashBox
    
    func geohashes(for boundingBox: GeodesicBoundingBox, precision: Int) -> [String]
    func geohashBoxes(for boundingBox: GeodesicBoundingBox, precision: Int) -> [GeoJsonGeohashBox]
    
    func geohashNeighbors(for point: GeodesicPoint, precision: Int) -> [String]
    func geohashBoxNeighbors(for point: GeodesicPoint, precision: Int) -> [GeoJsonGeohashBox]
    
    func geohashBox(for geohash: String) -> GeoJsonGeohashBox?
}

public struct GeohashCoder: GeohashCoderProtocol {
    /**
     Returns a geohash associated to the coordinate
     
     - point: The point used to create geohash
     - precision: How precise of a geohash to use
     
     - returns: A geohash
     */
    public func geohash(for point: GeodesicPoint, precision: Int) -> String { geohashBox(point: point, precision: precision).geohash }
    public func geohashBox(for point: GeodesicPoint, precision: Int) -> GeoJsonGeohashBox { geohashBox(point: point, precision: precision) }
    
    /**
     Returns an array of geohashes associated to the boundingbox
     
     - boundingBox: The boundingBox used to create geohashes
     - precision: How precise of a geohash to use
     
     - returns: An array of geohashes
     */
    public func geohashes(for boundingBox: GeodesicBoundingBox, precision: Int) -> [String] { geohashBoxes(boundingBox: boundingBox, precision: precision).map { $0.geohash } }
    public func geohashBoxes(for boundingBox: GeodesicBoundingBox, precision: Int) -> [GeoJsonGeohashBox] { geohashBoxes(boundingBox: boundingBox, precision: precision) }
    
    /**
     Returns a geohash with neighbors associated to the coordinate
     
     - point: The point used to create geohash
     - precision: How precise of a geohash to use
     
     - returns: A geohash
     */
    public func geohashNeighbors(for point: GeodesicPoint, precision: Int) -> [String] { neighbors(geohash: geohashBox(point: point, precision: precision).geohash) }
    public func geohashBoxNeighbors(for point: GeodesicPoint, precision: Int) -> [GeoJsonGeohashBox] { neighbors(geohash: geohashBox(point: point, precision: precision).geohash).map { geohashBox(geohash: $0)! } }
    
    /**
     Returns a geohashBox associated to the geohash
     
     - geohash: The geohash used to create geohashBox
     
     - returns: A geohashBox
     */
    public func geohashBox(for geohash: String) -> GeoJsonGeohashBox? { geohashBox(geohash: geohash) }
    
    /**
     Returns a geohash with neighbors associated to the geohash
     
     - geohash: The geohash used to create neighbors
     
     - returns: A geohash
     */
    public func neighbors(for geohash: String) -> [String] { neighbors(geohash: geohash) }
}

// MARK: Private

private let decimalToBase32Characters: [Character] = "0123456789bcdefghjkmnpqrstuvwxyz".map { $0 }
private let base32BitflowInit: UInt8 = 0b10000

private let neighborCodeByIndex1 = "p0r21436x8zb9dcf5h7kjnmqesgutwvy".enumerated().reduce(into: [Character: Int]()) { $0[$1.element] = $1.offset }
private let neighborCodeByIndex2 = "14365h7k9dcfesgujnmqp0r2twvyx8zb".enumerated().reduce(into: [Character: Int]()) { $0[$1.element] = $1.offset }
private let neighborCodeByIndex3 = "bc01fg45238967deuvhjyznpkmstqrwx".enumerated().reduce(into: [Character: Int]()) { $0[$1.element] = $1.offset }
private let neighborCodeByIndex4 = "238967debc01fg45kmstqrwxuvhjyznp".enumerated().reduce(into: [Character: Int]()) { $0[$1.element] = $1.offset }

private let borderCodeSet1 = "prxz".reduce(into: Set<Character>()) { $0.insert($1) }
private let borderCodeSet2 = "028b".reduce(into: Set<Character>()) { $0.insert($1) }
private let borderCodeSet3 = "bcfguvyz".reduce(into: Set<Character>()) { $0.insert($1) }
private let borderCodeSet4 = "0145hjnp".reduce(into: Set<Character>()) { $0.insert($1) }

extension GeohashCoder {
    private func geohashBox(point: GeodesicPoint, precision: Int) -> GeoJsonGeohashBox {
        var range = (longitude: (min: -180.0, max: 180.0), latitude: (min: -90.0, max: 90.0))
        
        var even = true
        var base32char = 0
        var bit = base32BitflowInit
        
        var geohash = ""
        
        let point = Calculator.normalize(point)
        
        repeat {
            if even {
                let center = (range.longitude.min + range.longitude.max) / 2
                if point.longitude >= center {
                    base32char |= Int(bit)
                    range.longitude.min = center
                } else {
                    range.longitude.max = center
                }
            } else {
                let center = (range.latitude.min + range.latitude.max) / 2
                if point.latitude >= center {
                    base32char |= Int(bit)
                    range.latitude.min = center
                } else {
                    range.latitude.max = center
                }
            }
            
            even = !even
            bit >>= 1
            
            if bit == 0b00000 {
                geohash += String(decimalToBase32Characters[base32char])
                bit = base32BitflowInit
                base32char = 0
            }
        } while geohash.count < precision
        
        let boundingCoordinates = (minLongitude: range.longitude.min, minLatitude: range.latitude.min, maxLongitude: range.longitude.max, maxLatitude: range.latitude.max)
        
        return GeohashBox(boundingCoordinates: boundingCoordinates, geohash: geohash)
    }
    
    private func geohashBoxes(boundingBox: GeodesicBoundingBox, precision: Int) -> [GeoJsonGeohashBox] {
        var geohashBoxes = [GeoJsonGeohashBox]()
        
        let point = SimplePoint(longitude: boundingBox.minLongitude, latitude: boundingBox.minLatitude)
        var longitudeGeohashBox = geohashBox(point: point, precision: precision)
        
        repeat {
            geohashBoxes.append(longitudeGeohashBox)
            
            var latitudeGeohashBox = geohashBox(geohash: adjacent(geohash: longitudeGeohashBox.geohash, direction: .north))!
            
            while latitudeGeohashBox.boundingBox.overlaps(boundingBox: boundingBox) {
                geohashBoxes.append(latitudeGeohashBox)
                
                latitudeGeohashBox = geohashBox(geohash: adjacent(geohash: latitudeGeohashBox.geohash, direction: .north))!
            }
            
            longitudeGeohashBox = geohashBox(geohash: adjacent(geohash: longitudeGeohashBox.geohash, direction: .east))!
        } while longitudeGeohashBox.boundingBox.overlaps(boundingBox: boundingBox)
        
        return geohashBoxes
    }
    
    private func geohashBox(geohash: String) -> GeoJsonGeohashBox? {
        var range = (longitude: (min: -180.0, max: 180.0), latitude: (min: -90.0, max: 90.0))
        
        var even = true
        
        for character in geohash {
            guard let bitmap = decimalToBase32Characters.firstIndex(of: character) else { Log.warning("Invalid geohash: \(geohash)"); return nil }
            
            var mask = Int(base32BitflowInit)
            
            while mask != 0 {
                if even {
                    let center = (range.longitude.min + range.longitude.max) / 2
                    if bitmap & mask != 0 {
                        range.longitude.min = center
                    } else {
                        range.longitude.max = center
                    }
                } else {
                    let center = (range.latitude.min + range.latitude.max) / 2
                    if bitmap & mask != 0 {
                        range.latitude.min = center
                    } else {
                        range.latitude.max = center
                    }
                }
                
                even = !even
                mask >>= 1
            }
        }
        
        let boundingCoordinates = (minLongitude: range.longitude.min, minLatitude: range.latitude.min, maxLongitude: range.longitude.max, maxLatitude: range.latitude.max)
        
        return GeohashBox(boundingCoordinates: boundingCoordinates, geohash: geohash)
    }
    
    private func neighbors(geohash: String) -> [String] {
        let north = adjacent(geohash: geohash, direction: .north)
        let east = adjacent(geohash: geohash, direction: .east)
        let south = adjacent(geohash: geohash, direction: .south)
        let west = adjacent(geohash: geohash, direction: .west)
        let northEast = adjacent(geohash: north, direction: .east)
        let southEast = adjacent(geohash: south, direction: .east)
        let southWest = adjacent(geohash: south, direction: .west)
        let northWest = adjacent(geohash: north, direction: .west)
        
        // in clockwise order
        return [north, northEast, east, southEast, south, southWest, west, northWest]
    }
    
    private func adjacent(geohash: String, direction: GeohashCompassPoint) -> String {
        // last character of hash
        let lastCharacter = geohash.last!
        // hash without last character
        var parent = geohash.dropLast().description
        
        let even = geohash.count % 2 == 0
        
        // check for edge-cases which don't share common prefix
        if !parent.isEmpty, borderContains(direction: direction, even: even, character: lastCharacter) {
            parent = adjacent(geohash: parent, direction: direction)
        }
        
        // append letter for direction to parent
        return parent + decimalToBase32Characters[neighborIndex(direction: direction, even: even, character: lastCharacter)].description
    }
    
    private func neighborIndex(direction: GeohashCompassPoint, even: Bool, character: Character) -> Int {
        switch direction {
        case .north: return even ? neighborCodeByIndex1[character]! : neighborCodeByIndex3[character]!
        case .south: return even ? neighborCodeByIndex2[character]! : neighborCodeByIndex4[character]!
        case .east: return even ? neighborCodeByIndex3[character]! : neighborCodeByIndex1[character]!
        case .west: return even ? neighborCodeByIndex4[character]! : neighborCodeByIndex2[character]!
        }
    }
    
    private func borderContains(direction: GeohashCompassPoint, even: Bool, character: Character) -> Bool {
        switch direction {
        case .north: return even ? borderCodeSet1.contains(character) : borderCodeSet3.contains(character)
        case .south: return even ? borderCodeSet2.contains(character) : borderCodeSet4.contains(character)
        case .east: return even ? borderCodeSet3.contains(character) : borderCodeSet1.contains(character)
        case .west: return even ? borderCodeSet4.contains(character) : borderCodeSet2.contains(character)
        }
    }
}
