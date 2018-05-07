let wktTestJson: String = """
{
	"wktObjects": [{
		"name": "Point",
		"wkt": "POINT (30 10)"
	},{
		"name": "LineString",
		"wkt": "LINESTRING (30 10, 10 30, 40 40)"
	},{
		"name": "Polygon",
		"wkt": "POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))"
	},{
		"name": "Polygon with hole",
		"wkt": "POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10), (20 30, 35 35, 30 20, 20 30))"
	},{
		"name": "Unsupported MultiPoint",
		"wkt": "MULTIPOINT ((10 40), (40 30), (20 20), (30 10))"
	},{
		"name": "Unsupported MultiPoint Alternative",
		"wkt": "MULTIPOINT (10 40, 40 30, 20 20, 30 10)"
	},{
		"name": "MultiLineString",
		"wkt": "MULTILINESTRING ((10 10, 20 20, 10 40), (40 40, 30 30, 40 20, 30 10))"
	},{
		"name": "MultiPolygon",
		"wkt": "MULTIPOLYGON (((30 20, 45 40, 10 40, 30 20)), ((15 5, 40 10, 10 20, 5 10, 15 5)))"
	},{
		"name": "MultiPolygon With Hole",
		"wkt": "MULTIPOLYGON (((40 40, 20 45, 45 30, 40 40)), ((20 35, 10 30, 10 10, 30 5, 45 20, 20 35), (30 20, 20 15, 20 25, 30 20)))"
	},{
		"name": "Unsupported GEOMETRYCOLLECTION",
		"wkt": "GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))"
	},{
		"name": "Unsupported POINT ZM",
		"wkt": "POINT ZM (1 1 5 60)"
	},{
		"name": "Unsupported POINT M",
		"wkt": "POINT M (1 1 80)"
	},{
		"name": "Unsupported POINT EMPTY",
		"wkt": "POINT EMPTY"
	},{
		"name": "Unsupported MULTIPOLYGON EMPTY",
		"wkt": "MULTIPOLYGON EMPTY"
	},{
		"name": "Unsupported CIRCULARSTRING",
		"wkt": "CIRCULARSTRING(1 5, 6 2, 7 3)"
	},{
		"name": "Unsupported COMPOUNDCURVE",
		"wkt": "COMPOUNDCURVE(CIRCULARSTRING(0 0,1 1,1 0),(1 0,0 1))"
	},{
		"name": "Unsupported CURVEPOLYGON",
		"wkt": "CURVEPOLYGON(CIRCULARSTRING(-2 0,-1 -1,0 0,1 -1,2 0,0 2,-2 0),(-1 0,0 0.5,1 0,0 1,-1 0))"
	},{
		"name": "Unsupported MULTICURVE",
		"wkt": "MULTICURVE((5 5,3 5,3 3,0 3),CIRCULARSTRING(0 0,2 1,2 2))"
	},{
		"name": "Unsupported TRIANGLE",
		"wkt": "TRIANGLE((0 0 0,0 1 0,1 1 0,0 0 0))"
	},{
		"name": "Unsupported TIN",
		"wkt": "TIN (((0 0 0, 0 0 1, 0 1 0, 0 0 0)), ((0 0 0, 0 1 0, 1 1 0, 0 0 0)))"
	},{
		"name": "Unsupported POLYHEDRALSURFACE",
		"wkt": "POLYHEDRALSURFACE Z (((0 0 0, 0 1 0, 1 1 0, 1 0 0, 0 0 0)), ((0 0 0, 0 1 0, 0 1 1, 0 0 1, 0 0 0)), ((0 0 0, 1 0 0, 1 0 1, 0 0 1, 0 0 0)), ((1 1 1, 1 0 1, 0 0 1, 0 1 1, 1 1 1)), ((1 1 1, 1 0 1, 1 0 0, 1 1 0, 1 1 1)), ((1 1 1, 1 1 0, 0 1 0, 0 1 1, 1 1 1)))"
	}]
}
"""
