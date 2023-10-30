
import Foundation
import geos

func makePoints(from geometry: GEOSObject) throws -> [GeoJson.Point] {
    guard let sequence = GEOSGeom_getCoordSeq_r(geometry.context.handle, geometry.pointer) else {
        throw GEOSError.libraryError(errorMessages: geometry.context.errors)
    }
    var count: UInt32 = 0
    // returns 0 on exception
    guard GEOSCoordSeq_getSize_r(geometry.context.handle, sequence, &count) != 0 else {
        throw GEOSError.libraryError(errorMessages: geometry.context.errors)
    }
    return try Array(0..<count).map { (index) -> GeoJson.Point in
        var point = GeoJson.Point(longitude: 0, latitude: 0)
        // returns 0 on exception
        guard GEOSCoordSeq_getX_r(geometry.context.handle, sequence, index, &point.longitude) != 0,
            GEOSCoordSeq_getY_r(geometry.context.handle, sequence, index, &point.latitude) != 0 else {
                throw GEOSError.libraryError(errorMessages: geometry.context.errors)
        }
        return point
    }
}

func makeGEOSObject(with context: GEOSContext,
                    points: [GeoJson.Point],
                    factory: (GEOSContext, OpaquePointer) -> OpaquePointer?) throws -> GEOSObject
{

    let sequence = try makeCoordinateSequence(with: context, points: points)
    guard let geometry = factory(context, sequence) else {
        GEOSCoordSeq_destroy_r(context.handle, sequence)
        throw GEOSError.libraryError(errorMessages: context.errors)
    }
    return GEOSObject(context: context, pointer: geometry)
}

func makeCoordinateSequence(with context: GEOSContext, points: [GeoJson.Point]) throws -> OpaquePointer {
    guard let sequence = GEOSCoordSeq_create_r(context.handle, UInt32(points.count), 2) else {
        throw GEOSError.libraryError(errorMessages: context.errors)
    }
    
    try points.enumerated().forEach { (i, point) in
        guard GEOSCoordSeq_setX_r(context.handle, sequence, UInt32(i), point.longitude) != 0,
            GEOSCoordSeq_setY_r(context.handle, sequence, UInt32(i), point.latitude) != 0 else {
                GEOSCoordSeq_destroy_r(context.handle, sequence)
                throw GEOSError.libraryError(errorMessages: context.errors)
        }
    }
    return sequence
}
