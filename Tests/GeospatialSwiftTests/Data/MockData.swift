import Foundation

@testable import GeospatialSwift

// swiftlint:disable force_cast force_try
final class MockData {
    static let geoJson = GeoJson()
    
    static let geoJsonTestData: [GeoJsonDictionary] = { json(jsonString: geoJsonTestJson)["geoJsonObjects"] as! [GeoJsonDictionary] }()
    static let wktTestData: [GeoJsonDictionary] = { json(jsonString: wktTestJson)["wktObjects"] as! [GeoJsonDictionary] }()
    
    static func testGeoJson(_ name: String) -> GeoJsonDictionary { geoJsonTestData.first { ($0["name"] as! String) == name }!["geoJson"] as! GeoJsonDictionary }
    
    static func testGeoJsonObject(geoJsonDataName: String) -> GeoJsonObject { geoJson.parseObject(fromValidatedGeoJson: testGeoJson(geoJsonDataName)) }
    
    static func testWkt(_ name: String) -> String { wktTestData.first { ($0["name"] as! String) == name }!["wkt"] as! String }
    
    static let point: GeoJson.Point = geoJson.point(longitude: 1, latitude: 2, altitude: 3)
    static let points: [GeoJson.Point] = linesPoints.first!
    static let lineStrings: [GeoJson.LineString] = linesPoints.map { geoJson.lineString(points: $0).success! }
    static let selfIntersectingLineStrings: [GeoJson.LineString] =  selfIntersectingLinesPoints.map { geoJson.lineString(points: $0).success! }
    static let selfCrossingLineStrings: [GeoJson.LineString] =  selfCrossingLinesPoints.map { geoJson.lineString(points: $0).success! }
    static let sharingStartAndEndLineStrings: [GeoJson.LineString] = sharingStartAndEndLinesPoints.map { geoJson.lineString(points: $0).success! }
    static let doubleNLineStrings: [GeoJson.LineString] = doubleNLinesPoints.map { geoJson.lineString(points: $0).success! }
    
    static let linearRings: [GeoJson.LineString] = linearRingsList.first!
    static let polygons: [GeoJson.Polygon] = linearRingsList.map { geoJson.polygon(mainRing: $0.first!, negativeRings: Array($0.dropFirst())).success! }
    static let sharingCornerLinearRings: [GeoJson.LineString] = sharingCornerRingsList.first!
    static let sharingCornerAndOverlappingRings: [GeoJson.LineString] = sharingCornerAndOverlappingRingsList.first!
    static let ringIntersectingLinearRings: [GeoJson.LineString] = ringIntersectingRingsList.first!
    static let holeOutsideLinearRings: [GeoJson.LineString] = holeOutsideRingsList.first!
    static let holeContainedLinearRings: [GeoJson.LineString] = holeContainedRingsList.first!
    static let mShapeMainRingLinearRings: [GeoJson.LineString] = mShapeMainRingRingsList.first!
    static let doubleMNegativeRingsLinearRings: [GeoJson.LineString] = doubleMNegativeRingsRingsList.first!
    static let diamondNegativeRingLinearRings: [GeoJson.LineString] = diamondNegativeRingRingsList.first!
    
    static let touchingPolygons: [GeoJson.Polygon] = touchingLinearRingsList.map { geoJson.polygon(mainRing: $0.first!, negativeRings: Array($0.dropFirst())).success! }
    static let sharingEdgePolygons: [GeoJson.Polygon] = sharingEdgeLinearRingsList.map { geoJson.polygon(mainRing: $0.first!, negativeRings: Array($0.dropFirst())).success! }
    static let containingPolygons: [GeoJson.Polygon] = containingPolygonsLinearRingsList.map { geoJson.polygon(mainRing: $0.first!, negativeRings: Array($0.dropFirst())).success! }
    
    static let geometries: [GeoJsonGeometry] = [
        MockData.point,
        geoJson.multiPoint(points: MockData.points).success!,
        geoJson.lineString(points: MockData.points).success!,
        geoJson.multiLineString(lineStrings: MockData.lineStrings).success!,
        geoJson.polygon(mainRing: MockData.linearRings.first!, negativeRings: Array(MockData.linearRings.dropFirst())).success!,
        geoJson.multiPolygon(polygons: MockData.polygons).success!
    ]
    static let features: [GeoJson.Feature] = [
        geoJson.feature(geometry: geoJson.point(longitude: 1, latitude: 2, altitude: 3), id: nil, properties: nil).success!,
        geoJson.feature(geometry: geoJson.lineString(points: MockData.points).success!, id: nil, properties: nil).success!,
        geoJson.feature(geometry: geoJson.polygon(mainRing: MockData.linearRings.first!, negativeRings: Array(MockData.linearRings.dropFirst())).success!, id: nil, properties: nil).success!
    ]
    
    static let pointsCoordinatesJson = [[1.0, 2.0, 3.0], [2.0, 2.0, 4.0], [2.0, 3.0, 3.0]]
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
    
    private static let linesPoints: [[GeoJson.Point]] = [
        [GeoTestHelper.point(1, 2, 3), GeoTestHelper.point(2, 2, 4), GeoTestHelper.point(2, 3, 3)],
        [GeoTestHelper.point(2, 3, 3), GeoTestHelper.point(3, 3, 4), GeoTestHelper.point(3, 4, 5), GeoTestHelper.point(4, 5, 6)]
    ]
    
    private static let selfIntersectingLinesPoints: [[GeoJson.Point]] = [
        [GeoTestHelper.point(21, 20, 3), GeoTestHelper.point(20, 21, 4), GeoTestHelper.point(20, 19, 5)],
        [GeoTestHelper.point(19, 20, 3), GeoTestHelper.point(23, 20, 4)]
    ]
    
    private static let selfCrossingLinesPoints: [[GeoJson.Point]] = [
        [GeoTestHelper.point(1, -1, 3), GeoTestHelper.point(0, 1, 4), GeoTestHelper.point(0, 0, 5)],
        [GeoTestHelper.point(0, 0, 5), GeoTestHelper.point(3, 0, 4)]
    ]
    
    private static let sharingStartAndEndLinesPoints: [[GeoJson.Point]] = [
        [GeoTestHelper.point(20, 20, 0), GeoTestHelper.point(20, 21, 0), GeoTestHelper.point(21, 21, 0)],
        [GeoTestHelper.point(20, 20, 0), GeoTestHelper.point(19, 20, 0)],
        [GeoTestHelper.point(21, 21, 0), GeoTestHelper.point(21, 22, 0)],
        [GeoTestHelper.point(20, 20, 0), GeoTestHelper.point(21, 20, 0), GeoTestHelper.point(21, 21, 0)],
        [GeoTestHelper.point(21, 21, 0), GeoTestHelper.point(22, 21, 0)]
    ]
    
    private static let doubleNLinesPoints: [[GeoJson.Point]] = [
        [GeoTestHelper.point(0, 0, 0), GeoTestHelper.point(3, 0, 0), GeoTestHelper.point(0, 1, 0), GeoTestHelper.point(3, 1, 0)],
        [GeoTestHelper.point(1, -1, 0), GeoTestHelper.point(1, 2, 0), GeoTestHelper.point(2, -1, 0), GeoTestHelper.point(2, 2, 0)]
    ]
    
    private static let polygonPoints: [[GeoJson.Point]] = polygonPointsList.first!
    
    private static let polygonPointsList: [[[GeoJson.Point]]] = [
        [
            [GeoTestHelper.point(0, 0, 3), GeoTestHelper.point(3, 0, 4), GeoTestHelper.point(3, 3, 5), GeoTestHelper.point(0, 3, 4), GeoTestHelper.point(0, 0, 3)],
            [GeoTestHelper.point(1, 1, 3), GeoTestHelper.point(1, 2, 4), GeoTestHelper.point(2, 2, 5), GeoTestHelper.point(2, 1, 4), GeoTestHelper.point(1, 1, 3)]
            
        ],
        [
            [GeoTestHelper.point(5, 6, 13), GeoTestHelper.point(6, 6, 14), GeoTestHelper.point(6, 7, 15), GeoTestHelper.point(5, 7, 14), GeoTestHelper.point(5, 6, 13)],
            [GeoTestHelper.point(6, 7, 13), GeoTestHelper.point(7, 7, 14), GeoTestHelper.point(7, 8, 15), GeoTestHelper.point(6, 8, 14), GeoTestHelper.point(6, 7, 13)]
        ]
    ]
    
    private static let linearRingsList: [[GeoJson.LineString]] = polygonPointsList.map { $0.map { geoJson.lineString(points: $0).success! } }
    
    private static let sharingCornerPolygonPointsList: [[[GeoJson.Point]]] = [
        [
            [GeoTestHelper.point(20, 20), GeoTestHelper.point(23, 20), GeoTestHelper.point(23, 23), GeoTestHelper.point(20, 23), GeoTestHelper.point(20, 20)],
            [GeoTestHelper.point(20, 20), GeoTestHelper.point(22, 21), GeoTestHelper.point(21, 22), GeoTestHelper.point(20, 20)]
        ]
    ]
    
    private static let sharingCornerRingsList: [[GeoJson.LineString]] = sharingCornerPolygonPointsList.map { $0.map { geoJson.lineString(points: $0).success! } }
    
    private static let sharingCornerAndOverlappingPolygonPointsList: [[[GeoJson.Point]]] = [
        [
            [GeoTestHelper.point(20, 0), GeoTestHelper.point(23, 0), GeoTestHelper.point(23, 3), GeoTestHelper.point(20, 3), GeoTestHelper.point(20, 0)],
            [GeoTestHelper.point(20, 0), GeoTestHelper.point(21, 0), GeoTestHelper.point(21, 1), GeoTestHelper.point(20, 1), GeoTestHelper.point(20, 0)]
        ]
    ]
    
    private static let sharingCornerAndOverlappingRingsList: [[GeoJson.LineString]] = sharingCornerAndOverlappingPolygonPointsList.map { $0.map { geoJson.lineString(points: $0).success! } }
    
    private static let ringIntersectingPolygonPointsList: [[[GeoJson.Point]]] = [
        [
            [GeoTestHelper.point(20, 20), GeoTestHelper.point(23, 20), GeoTestHelper.point(23, 23), GeoTestHelper.point(20, 23), GeoTestHelper.point(20, 20)],
            [GeoTestHelper.point(22, 21), GeoTestHelper.point(24, 21), GeoTestHelper.point(24, 22), GeoTestHelper.point(22, 22), GeoTestHelper.point(22, 21)]
        ]
    ]
    
    private static let ringIntersectingRingsList: [[GeoJson.LineString]] = ringIntersectingPolygonPointsList.map { $0.map { geoJson.lineString(points: $0).success! } }
    
    private static let holeOutsidePolygonPointsList: [[[GeoJson.Point]]] = [
        [
            [GeoTestHelper.point(20, 20), GeoTestHelper.point(23, 20), GeoTestHelper.point(23, 23), GeoTestHelper.point(20, 23), GeoTestHelper.point(20, 20)],
            [GeoTestHelper.point(25, 25), GeoTestHelper.point(26, 25), GeoTestHelper.point(26, 26), GeoTestHelper.point(25, 26), GeoTestHelper.point(25, 25)]
        ]
    ]
    
    private static let holeOutsideRingsList: [[GeoJson.LineString]] = holeOutsidePolygonPointsList.map { $0.map { geoJson.lineString(points: $0).success! } }
    
    private static let holeContainedPolygonPointsList: [[[GeoJson.Point]]] = [
        [
            [GeoTestHelper.point(20, 20), GeoTestHelper.point(25, 20), GeoTestHelper.point(25, 25), GeoTestHelper.point(20, 25), GeoTestHelper.point(20, 20)],
            [GeoTestHelper.point(21, 21), GeoTestHelper.point(24, 21), GeoTestHelper.point(24, 24), GeoTestHelper.point(21, 24), GeoTestHelper.point(21, 21)],
            [GeoTestHelper.point(22, 22), GeoTestHelper.point(23, 22), GeoTestHelper.point(23, 23), GeoTestHelper.point(22, 23), GeoTestHelper.point(22, 22)]
        ]
    ]
    
    private static let holeContainedRingsList: [[GeoJson.LineString]] = holeContainedPolygonPointsList.map { $0.map { geoJson.lineString(points: $0).success! } }
    
    private static let mShapeMainRingPolygonPointsList: [[[GeoJson.Point]]] = [
        [
            [GeoTestHelper.point(20, 20), GeoTestHelper.point(24, 20), GeoTestHelper.point(24, 26), GeoTestHelper.point(22, 22), GeoTestHelper.point(20, 26), GeoTestHelper.point(20, 20)],
            [GeoTestHelper.point(21, 21), GeoTestHelper.point(23, 21), GeoTestHelper.point(23, 23), GeoTestHelper.point(21, 23), GeoTestHelper.point(21, 21)]
        ]
    ]
    
    private static let mShapeMainRingRingsList: [[GeoJson.LineString]] = mShapeMainRingPolygonPointsList.map { $0.map { geoJson.lineString(points: $0).success! } }
    
    private static let doubleMNegativeRingsPolygonPointsList: [[[GeoJson.Point]]] = [
        [
            [GeoTestHelper.point(20, 20), GeoTestHelper.point(26, 20), GeoTestHelper.point(26, 26), GeoTestHelper.point(20, 26), GeoTestHelper.point(20, 20)],
            [GeoTestHelper.point(21, 21), GeoTestHelper.point(23, 21), GeoTestHelper.point(22, 22), GeoTestHelper.point(23, 23), GeoTestHelper.point(21, 23), GeoTestHelper.point(21, 21)],
            [GeoTestHelper.point(23, 21), GeoTestHelper.point(25, 21), GeoTestHelper.point(25, 23), GeoTestHelper.point(23, 23), GeoTestHelper.point(24, 22), GeoTestHelper.point(23, 21)]
        ]
    ]
    
    private static let doubleMNegativeRingsRingsList: [[GeoJson.LineString]] = doubleMNegativeRingsPolygonPointsList.map { $0.map { geoJson.lineString(points: $0).success! } }
    
    private static let diamondNegativeRingPolygonPointsList: [[[GeoJson.Point]]] = [
        [
            [GeoTestHelper.point(20, 20), GeoTestHelper.point(24, 20), GeoTestHelper.point(24, 24), GeoTestHelper.point(20, 24), GeoTestHelper.point(20, 20)],
            [GeoTestHelper.point(20, 20), GeoTestHelper.point(23, 21), GeoTestHelper.point(24, 24), GeoTestHelper.point(21, 23), GeoTestHelper.point(20, 20)]
        ]
    ]
    
    private static let diamondNegativeRingRingsList: [[GeoJson.LineString]] = diamondNegativeRingPolygonPointsList.map { $0.map { geoJson.lineString(points: $0).success! } }
    
    private static let touchingPolygonPointsList: [[[GeoJson.Point]]] = [
        [
            [GeoTestHelper.point(20, 20), GeoTestHelper.point(20, 21), GeoTestHelper.point(21, 21), GeoTestHelper.point(21, 20), GeoTestHelper.point(20, 20)]
        ],
        [
            [GeoTestHelper.point(21, 21), GeoTestHelper.point(21, 22), GeoTestHelper.point(22, 22), GeoTestHelper.point(22, 21), GeoTestHelper.point(21, 21)]
        ]
    ]
    
    private static let touchingLinearRingsList: [[GeoJson.LineString]] = touchingPolygonPointsList.map { $0.map { geoJson.lineString(points: $0).success! } }
    
    private static let sharingEdgePolygonPointsList: [[[GeoJson.Point]]] = [
        [
            [GeoTestHelper.point(20, 20), GeoTestHelper.point(20, 21), GeoTestHelper.point(21, 21), GeoTestHelper.point(21, 20), GeoTestHelper.point(20, 20)]
        ],
        [
            [GeoTestHelper.point(21, 20), GeoTestHelper.point(22, 20), GeoTestHelper.point(22, 21), GeoTestHelper.point(21, 21), GeoTestHelper.point(21, 20)]
        ]
    ]
    
    private static let sharingEdgeLinearRingsList: [[GeoJson.LineString]] = sharingEdgePolygonPointsList.map { $0.map { geoJson.lineString(points: $0).success! } }
    
    private static let containingPolygonsPointsList: [[[GeoJson.Point]]] = [
        [
            [GeoTestHelper.point(20, 20), GeoTestHelper.point(20, 24), GeoTestHelper.point(24, 24), GeoTestHelper.point(24, 20), GeoTestHelper.point(20, 20)]
        ],
        [
            [GeoTestHelper.point(21, 21), GeoTestHelper.point(22, 21), GeoTestHelper.point(22, 22), GeoTestHelper.point(21, 22), GeoTestHelper.point(21, 21)]
        ]
    ]
    
    private static let containingPolygonsLinearRingsList: [[GeoJson.LineString]] = containingPolygonsPointsList.map { $0.map { geoJson.lineString(points: $0).success! } }
}
