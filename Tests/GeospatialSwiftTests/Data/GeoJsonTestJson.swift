let geoJsonTestJson: String = """
{
	"geoJsonObjects": [{
		"name": "Point",
		"geoJson": {
			"type": "Point",
			"coordinates": [100.0, 0.0]
		}
	}, {
		"name": "MultiPoint",
		"geoJson": {
			"type": "MultiPoint",
			"coordinates": [
				[100.0, 0.0],
				[101.0, 1.0]
			]
		}
	}, {
		"name": "LineString",
		"geoJson": {
			"type": "LineString",
			"coordinates": [
				[100.0, 0.0],
				[101.0, 1.0]
			]
		}
	}, {
		"name": "MultiLineString",
		"geoJson": {
			"type": "MultiLineString",
			"coordinates": [
				[
					[100.0, 0.0],
					[101.0, 1.0]
				],
				[
					[102.0, 2.0],
					[103.0, 3.0]
				]
			]
		}
	}, {
		"name": "Polygon",
		"geoJson": {
			"type": "Polygon",
			"coordinates": [
				[
					[100.0, 0.0],
					[101.0, 0.0],
					[101.0, 1.0],
					[100.0, 1.0],
					[100.0, 0.0]
				]
			]
		}
	}, {
		"name": "Polygon: Multiple Rings",
		"geoJson": {
			"type": "Polygon",
			"coordinates": [
				[
					[100.0, 0.0],
					[101.0, 0.0],
					[101.0, 1.0],
					[100.0, 1.0],
					[100.0, 0.0]
				],
				[
					[100.2, 0.2],
					[100.8, 0.2],
					[100.8, 0.8],
					[100.2, 0.8],
					[100.2, 0.2]
				]
			]
		}
	}, {
		"name": "MultiPolygon",
		"geoJson": {
			"type": "MultiPolygon",
			"coordinates": [
				[
					[
						[102.0, 2.0],
						[103.0, 2.0],
						[103.0, 3.0],
						[102.0, 3.0],
						[102.0, 2.0]
					]
				],
				[
					[
						[100.0, 0.0],
						[101.0, 0.0],
						[101.0, 1.0],
						[100.0, 1.0],
						[100.0, 0.0]
					],
					[
						[100.2, 0.2],
						[100.8, 0.2],
						[100.8, 0.8],
						[100.2, 0.8],
						[100.2, 0.2]
					]
				]
			]
		}
	}, {
		"name": "GeometryCollection",
		"geoJson": {
			"type": "GeometryCollection",
			"geometries": [{
					"type": "Point",
					"coordinates": [100.0, 0.0]
				},
				{
					"type": "LineString",
					"coordinates": [
						[101.0, 0.0],
						[102.0, 1.0]
					]
				}
			]
		}
	}, {
		"name": "GeometryCollection: Empty geometries",
		"geoJson": {
			"type": "GeometryCollection",
			"geometries": []
		}
	}, {
		"name": "Feature",
		"geoJson": {
			"type": "Feature",
			"bbox": [-10.0, -10.0, 10.0, 10.0],
			"geometry": {
				"type": "Polygon",
				"coordinates": [
					[
						[-10.0, -10.0],
						[10.0, -10.0],
						[10.0, 10.0],
						[-10.0, 10.0],
						[-10.0, -10.0]
					]
				]
			},
			"properties": {
				"prop0": "value0",
				"prop1": {
					"this": "that"
				}
			},
			"id": "12345"
		}
	}, {
		"name": "Feature: Geometry Collection",
		"geoJson": {
			"type": "Feature",
			"bbox": [-10.0, -10.0, 10.0, 10.0],
			"geometry": {
				"type": "GeometryCollection",
				"geometries": [{
						"type": "Point",
						"coordinates": [100.0, 0.0]
					},
					{
						"type": "LineString",
						"coordinates": [
							[101.0, 0.0],
							[102.0, 1.0]
						]
					},
					{
						"type": "Polygon",
						"coordinates": [
							[
								[100.0, 0.0],
								[101.0, 0.0],
								[101.0, 1.0],
								[100.0, 1.0],
								[100.0, 0.0]
							]
						]
					}
				]
			}
		}
	}, {
		"name": "Feature: null geometry",
		"geoJson": {
			"type": "Feature",
			"bbox": [-10.0, -10.0, 10.0, 10.0],
			"geometry": null
		}
	}, {
		"name": "FeatureCollection",
		"geoJson": {
			"type": "FeatureCollection",
			"features": [{
					"type": "Feature",
					"geometry": {
						"type": "Point",
						"coordinates": [102.0, 0.5]
					},
					"properties": {
						"prop0": "value0"
					},
					"id": "12345"
				},
				{
					"type": "Feature",
					"geometry": {
						"type": "LineString",
						"coordinates": [
							[102.0, 0.0],
							[103.0, 1.0],
							[104.0, 0.0],
							[105.0, 1.0]
						]
					},
					"properties": {
						"prop0": "value0",
						"prop1": 0.0
					}
				},
				{
					"type": "Feature",
					"geometry": {
						"type": "Polygon",
						"coordinates": [
							[
								[100.0, 0.0],
								[101.0, 0.0],
								[101.0, 1.0],
								[100.0, 1.0],
								[100.0, 0.0]
							]
						]
					},
					"properties": {
						"prop0": "value0",
						"prop1": {
							"this": "that"
						}
					}
				}
			]
		}
	}, {
		"name": "FeatureCollection: 2 Features, 1 null geometry",
		"geoJson": {
			"type": "FeatureCollection",
			"features": [{
					"type": "Feature",
					"geometry": null,
					"properties": null,
					"id": null
				},
				{
					"type": "Feature",
					"geometry": {
						"type": "LineString",
						"coordinates": [
							[102.0, 0.0],
							[103.0, 1.0],
							[104.0, 0.0],
							[105.0, 1.0]
						]
					},
					"properties": {
						"prop0": "value0",
						"prop1": 0.0
					}
				}
			]
		}
	}, {
		"name": "FeatureCollection: 1 Feature, null geometry",
		"geoJson": {
			"type": "FeatureCollection",
			"features": [{
				"type": "Feature",
				"geometry": null,
				"properties": {
					"prop0": "value0"
				}
			}]
		}
	}]
}
"""
