import Foundation

@testable import GeospatialSwift

// swiftlint:disable force_cast force_try
final class MockData {
    static let geoJson = GeoJson()
    
    static let geoJsonTestData: [GeoJsonDictionary] = { return json(jsonString: geoJsonTestJson)["geoJsonObjects"] as! [GeoJsonDictionary] }()
    static let wktTestData: [GeoJsonDictionary] = { return json(jsonString: wktTestJson)["wktObjects"] as! [GeoJsonDictionary] }()
    
    static func testGeoJson(_ name: String) -> GeoJsonDictionary {
        return geoJsonTestData.first { ($0["name"] as! String) == name }!["geoJson"] as! GeoJsonDictionary
    }
    
    static func testGeoJsonObject(geoJsonDataName: String) -> GeoJsonObject {
        return geoJson.parse(geoJson: testGeoJson(geoJsonDataName))!
    }
    
    static func testWkt(_ name: String) -> String {
        return wktTestData.first { ($0["name"] as! String) == name }!["wkt"] as! String
    }
    
    static let point: GeoJsonPoint = geoJson.point(longitude: 1, latitude: 2, altitude: 3)
    static let points: [GeoJsonPoint] = linesPoints.first!
    static let lineStrings: [GeoJsonLineString] = linesPoints.map { geoJson.lineString(points: $0)! }
    static let selfIntersectingLineStrings: [GeoJsonLineString] =  selfIntersectingLinesPoints.map { geoJson.lineString(points: $0)! }
    static let linearRings: [GeoJsonLineString] = linearRingsList.first!
    static let polygons: [GeoJsonPolygon] = linearRingsList.map { geoJson.polygon(linearRings: $0)! }
    static let touchingPolygons: [GeoJsonPolygon] = touchingLinearRingsList.map { geoJson.polygon(linearRings: $0)! }
    static let sharingEdgePolygons: [GeoJsonPolygon] = sharingEdgeLinearRingsList.map { geoJson.polygon(linearRings: $0)! }
    static let geometries: [GeoJsonGeometry] = [
        MockData.point,
        geoJson.multiPoint(points: MockData.points)!,
        geoJson.lineString(points: MockData.points)!,
        geoJson.multiLineString(lineStrings: MockData.lineStrings)!,
        geoJson.polygon(linearRings: MockData.linearRings)!,
        geoJson.multiPolygon(polygons: MockData.polygons)!
    ]
    static let features: [GeoJsonFeature] = [
        geoJson.feature(geometry: geoJson.point(longitude: 1, latitude: 2, altitude: 3), id: nil, properties: nil)!,
        geoJson.feature(geometry: geoJson.lineString(points: MockData.points)!, id: nil, properties: nil)!,
        geoJson.feature(geometry: geoJson.polygon(linearRings: MockData.linearRings)!, id: nil, properties: nil)!
    ]
    
    static let pointsCoordinatesJson = [[1.0, 2.0, 3.0], [2.0, 2.0, 4.0], [2.0, 3.0, 5.0]]
    static let lineStringsCoordinatesJson = [[[1.0, 2.0, 3.0], [2.0, 2.0, 4.0], [2.0, 3.0, 3.0]], [[2.0, 3.0, 3.0], [3.0, 3.0, 4.0], [3.0, 4.0, 5.0], [4.0, 5.0, 6.0]]]
    static let linearRingsCoordinatesJson = [[[0.0, 0.0, 3.0], [3.0, 0.0, 4.0], [3.0, 3.0, 5.0], [0.0, 3.0, 4.0]], [[1.0, 1.0, 3.0], [1.0, 2.0, 4.0], [2.0, 2.0, 5.0], [2.0, 1.0, 4.0]]]
    
    private static let partialPolygonsCoordinates1 = [[0.0, 0.0, 3.0], [3.0, 0.0, 4.0], [3.0, 3.0, 5.0], [0.0, 3.0, 4.0], [0.0, 0.0, 3.0]]
    private static let partialPolygonsCoordinates2 = [[1.0, 1.0, 3.0], [1.0, 2.0, 4.0], [2.0, 2.0, 5.0], [2.0, 1.0, 4.0], [1.0, 1.0, 3.0]]
    private static let partialPolygonsCoordinates3 = [[5.0, 6.0, 13.0], [6.0, 6.0, 14.0], [6.0, 7.0, 15.0], [5.0, 7.0, 14.0], [5.0, 6.0, 13.0]]
    private static let partialPolygonsCoordinates4 = [[6.0, 7.0, 13.0], [7.0, 7.0, 14.0], [7.0, 8.0, 15.0], [6.0, 8.0, 14.0], [6.0, 7.0, 13.0]]
    static let polygonsCoordinatesJson = [[partialPolygonsCoordinates1, partialPolygonsCoordinates2], [partialPolygonsCoordinates3, partialPolygonsCoordinates4]]
    
    static let box: GeodesicPolygon = SimplePolygon(mainRing:
        SimpleLine(points: [SimplePoint(longitude: 0, latitude: 0), SimplePoint(longitude: 0, latitude: 1), SimplePoint(longitude: 1, latitude: 1), SimplePoint(longitude: 1, latitude: 0), SimplePoint(longitude: 0, latitude: 0)])!)!
}

extension MockData {
    private static func json(jsonString: String) -> GeoJsonDictionary {
        let jsonData = try! JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!)
        
        return jsonData as! GeoJsonDictionary
    }
    
    private static let linesPoints: [[GeoJsonPoint]] = [
        [GeoTestHelper.point(1, 2, 3), GeoTestHelper.point(2, 2, 4), GeoTestHelper.point(2, 3, 3)],
        [GeoTestHelper.point(2, 3, 3), GeoTestHelper.point(3, 3, 4), GeoTestHelper.point(3, 4, 5), GeoTestHelper.point(4, 5, 6)]
    ]
    
    private static let selfIntersectingLinesPoints: [[GeoJsonPoint]] = [
        [GeoTestHelper.point(1, 0, 3), GeoTestHelper.point(0, 1, 4), GeoTestHelper.point(0, 0, 5)],
        [GeoTestHelper.point(0, 0, 3), GeoTestHelper.point(3, 0, 4)]
    ]
    
    private static let polygonPoints: [[GeoJsonPoint]] = polygonPointsList.first!
    
    private static let polygonPointsList: [[[GeoJsonPoint]]] = [
        [
            [GeoTestHelper.point(0, 0, 3), GeoTestHelper.point(3, 0, 4), GeoTestHelper.point(3, 3, 5), GeoTestHelper.point(0, 3, 4), GeoTestHelper.point(0, 0, 3)],
            [GeoTestHelper.point(1, 1, 3), GeoTestHelper.point(1, 2, 4), GeoTestHelper.point(2, 2, 5), GeoTestHelper.point(2, 1, 4), GeoTestHelper.point(1, 1, 3)]
        ],
        [
            [GeoTestHelper.point(5, 6, 13), GeoTestHelper.point(6, 6, 14), GeoTestHelper.point(6, 7, 15), GeoTestHelper.point(5, 7, 14), GeoTestHelper.point(5, 6, 13)],
            [GeoTestHelper.point(6, 7, 13), GeoTestHelper.point(7, 7, 14), GeoTestHelper.point(7, 8, 15), GeoTestHelper.point(6, 8, 14), GeoTestHelper.point(6, 7, 13)]
        ]
    ]
    
    private static let linearRingsList: [[GeoJsonLineString]] = polygonPointsList.map { $0.map { geoJson.lineString(points: $0)! } }
    
    private static let touchingPolygonPointsList: [[[GeoJsonPoint]]] = [
        [
            [GeoTestHelper.point(0, 0), GeoTestHelper.point(0, 1), GeoTestHelper.point(1, 1), GeoTestHelper.point(1, 0), GeoTestHelper.point(0, 0)]
        ],
        [
            [GeoTestHelper.point(1, 1), GeoTestHelper.point(1, 2), GeoTestHelper.point(2, 2), GeoTestHelper.point(2, 1), GeoTestHelper.point(1, 1)]
        ]
    ]
    
    private static let touchingLinearRingsList: [[GeoJsonLineString]] = touchingPolygonPointsList.map { $0.map { geoJson.lineString(points: $0)! } }
    
    private static let sharingEdgePolygonPointsList: [[[GeoJsonPoint]]] = [
        [
            [GeoTestHelper.point(0, 0), GeoTestHelper.point(0, 1), GeoTestHelper.point(1, 1), GeoTestHelper.point(1, 0), GeoTestHelper.point(0, 0)]
        ],
        [
            [GeoTestHelper.point(1, 0), GeoTestHelper.point(2, 0), GeoTestHelper.point(2, 1), GeoTestHelper.point(1, 1), GeoTestHelper.point(1, 0)]
        ]
    ]
    
    private static let sharingEdgeLinearRingsList: [[GeoJsonLineString]] = sharingEdgePolygonPointsList.map { $0.map { geoJson.lineString(points: $0)! } }
}
