public protocol GeohashCoderProtocol {
    func geohash(for point: GeodesicPoint, precision: Int) -> String
    
    func geohashBox(for point: GeodesicPoint, precision: Int) -> GeoJsonGeohashBox
    
    func geohashBox(geohash: String) -> GeoJsonGeohashBox?
    
    func geohashes(for boundingBox: GeoJsonBoundingBox, precision: Int) -> [String]
    
    func geohashBoxes(for boundingBox: GeoJsonBoundingBox, precision: Int) -> [GeoJsonGeohashBox]
    
    func geohashWithNeighbors(for point: GeodesicPoint, precision: Int) -> [String]
}

public struct GeohashCoder: GeohashCoderProtocol {
    internal let logger: LoggerProtocol
    internal let geodesicCalculator: GeodesicCalculatorProtocol
    
    /**
     Returns a geohash associated to the coordinate
     
     - point: The point used to create geohash
     - precision: How precise of a geohash to use
     
     - returns: A geohash
     */
    public func geohash(for point: GeodesicPoint, precision: Int) -> String {
        return transform(point: point, precision: precision).geohash
    }
    
    /**
     Returns a geohashBox associated to the geohash
     
     - geohash: The geohash used to create geohashBox
     
     - returns: A geohashBox
     */
    public func geohashBox(geohash: String) -> GeoJsonGeohashBox? {
        return transform(geohash: geohash)
    }
    public func geohashBox(for point: GeodesicPoint, precision: Int) -> GeoJsonGeohashBox {
        return transform(point: point, precision: precision)
    }
    
    /**
     Returns an array of geohashes associated to the boundingbox
     
     - boundingBox: The boundingBox used to create geohashes
     - precision: How precise of a geohash to use
     
     - returns: An array of geohashes
     */
    public func geohashes(for boundingBox: GeoJsonBoundingBox, precision: Int) -> [String] {
        return transform(boundingBox: boundingBox, precision: precision).map { $0.geohash }
    }
    public func geohashBoxes(for boundingBox: GeoJsonBoundingBox, precision: Int) -> [GeoJsonGeohashBox] {
        return transform(boundingBox: boundingBox, precision: precision)
    }
    
    /**
     Returns a geohash with neighbors associated to the coordinate
     
     - point: The point used to create geohash
     - precision: How precise of a geohash to use
     
     - returns: A geohash
     */
    public func geohashWithNeighbors(for point: GeodesicPoint, precision: Int) -> [String] {
        let geohashBox = transform(point: point, precision: precision)
        var neighborGeohashBoxes = neighborGeohashes(geohashBox: geohashBox, precision: precision)
        neighborGeohashBoxes.append(geohashBox)
        return neighborGeohashBoxes.map { $0.geohash }
    }
}

// MARK: Private

private enum Parity {
    case even, odd
    
    prefix static func ! (parity: Parity) -> Parity {
        return parity == .even ? .odd : .even
    }
}

private let decimalToBase32Map = "0123456789bcdefghjkmnpqrstuvwxyz".map { $0 }
private let base32BitflowInit: UInt8 = 0b10000

extension GeohashCoder {
    fileprivate func neighborGeohashes(geohashBox: GeoJsonGeohashBox, precision: Int) -> [GeoJsonGeohashBox] {
        let northGeohash = geohashBox.geohashNeighbor(direction: .north, precision: precision)
        let eastGeohash = geohashBox.geohashNeighbor(direction: .east, precision: precision)
        let southGeohash = geohashBox.geohashNeighbor(direction: .south, precision: precision)
        let westGeohash = geohashBox.geohashNeighbor(direction: .west, precision: precision)
        
        let northWestGeohash = northGeohash.geohashNeighbor(direction: .west, precision: precision)
        let northEastGeohash = northGeohash.geohashNeighbor(direction: .east, precision: precision)
        let southEastGeohash = southGeohash.geohashNeighbor(direction: .east, precision: precision)
        let southWestGeohash = southGeohash.geohashNeighbor(direction: .west, precision: precision)
        
        // in clockwise order
        return [northWestGeohash, northGeohash, northEastGeohash, eastGeohash, southEastGeohash, southGeohash, southWestGeohash, westGeohash]
    }
    
    fileprivate func transform(point: GeodesicPoint, precision: Int) -> GeoJsonGeohashBox {
        var range = (longitude: (min: -180.0, max: 180.0), latitude: (min: -90.0, max: 90.0))
        
        var parity = Parity.even
        var base32char = 0
        var bit = base32BitflowInit
        
        var geohash = ""
        
        let point = geodesicCalculator.normalize(point: point)
        
        repeat {
            switch parity {
            case .even:
                let center = (range.longitude.min + range.longitude.max) / 2
                if point.longitude >= center {
                    base32char |= Int(bit)
                    range.longitude.min = center
                } else {
                    range.longitude.max = center
                }
            case .odd:
                let center = (range.latitude.min + range.latitude.max) / 2
                if point.latitude >= center {
                    base32char |= Int(bit)
                    range.latitude.min = center
                } else {
                    range.latitude.max = center
                }
            }
            
            parity = !parity
            bit >>= 1
            
            if bit == 0b00000 {
                geohash += String(decimalToBase32Map[base32char])
                bit = base32BitflowInit
                base32char = 0
            }
        } while geohash.count < precision
        
        let boundingCoordinates = (minLongitude: range.longitude.min, minLatitude: range.latitude.min, maxLongitude: range.longitude.max, maxLatitude: range.latitude.max)
        
        return GeohashBox(boundingCoordinates: boundingCoordinates, geohashCoder: self, geohash: geohash)
    }
    
    fileprivate func transform(boundingBox: GeoJsonBoundingBox, precision: Int) -> [GeoJsonGeohashBox] {
        var geohashBoxes = [GeoJsonGeohashBox]()
        
        let point = SimplePoint(longitude: boundingBox.minLongitude, latitude: boundingBox.minLatitude)
        var longitudeGeohashBox = transform(point: point, precision: precision)
        
        repeat {
            geohashBoxes.append(longitudeGeohashBox)
            
            var latitudeGeohashBox = longitudeGeohashBox.geohashNeighbor(direction: .north, precision: precision)
            
            while latitudeGeohashBox.overlaps(boundingBox: boundingBox) {
                geohashBoxes.append(latitudeGeohashBox)
                
                latitudeGeohashBox = latitudeGeohashBox.geohashNeighbor(direction: .north, precision: precision)
            }
            
            longitudeGeohashBox = longitudeGeohashBox.geohashNeighbor(direction: .east, precision: precision)
        } while longitudeGeohashBox.overlaps(boundingBox: boundingBox)
        
        return geohashBoxes
    }
    
    fileprivate func transform(geohash: String) -> GeoJsonGeohashBox? {
        var range = (longitude: (min: -180.0, max: 180.0), latitude: (min: -90.0, max: 90.0))
        
        var parity = Parity.even
        
        for character in geohash {
            guard let bitmap = decimalToBase32Map.index(of: character) else { logger.error("Invalid geohash: \(geohash)"); return nil }
            
            var mask = Int(base32BitflowInit)
            
            while mask != 0 {
                switch parity {
                case .even:
                    let center = (range.longitude.min + range.longitude.max) / 2
                    if bitmap & mask != 0 {
                        range.longitude.min = center
                    } else {
                        range.longitude.max = center
                    }
                case .odd:
                    let center = (range.latitude.min + range.latitude.max) / 2
                    if bitmap & mask != 0 {
                        range.latitude.min = center
                    } else {
                        range.latitude.max = center
                    }
                }
                
                parity = !parity
                mask >>= 1
            }
        }
        
        let boundingCoordinates = (minLongitude: range.longitude.min, minLatitude: range.latitude.min, maxLongitude: range.longitude.max, maxLatitude: range.latitude.max)
        
        return GeohashBox(boundingCoordinates: boundingCoordinates, geohashCoder: self, geohash: geohash)
    }
}
