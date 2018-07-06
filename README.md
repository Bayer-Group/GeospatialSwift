# GeospatialSwift

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift 4.1](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20Linux%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-green.svg?style=flat)](https://swift.org/package-manager/)

What is GeospatialSwift?

GeospatialSwift is an interface to translate a GeoJson document / dictionary into a swift object which fully conforms to the more recent [GeoJson specification - August 2016](https://tools.ietf.org/html/rfc7946).

A GeoJsonObject can be transformed to a bounding box.

## Features

* Unit tested with high coverage
* Ongoing development

## Installation

### Carthage

```github "MonsantoCo/GeospatialSwift" ~> 0.1.0```

### Package Manager

```.package(url: "git@github.com:MonsantoCo/GeospatialSwift.git", from: "0.1.0")```

## Geospatial

Geospatial

* The main interface consisting of 4 sub interface

### GeoJson

Geospatial.geoJson

* Full GeoJson specification support to create a GeoJsonObject
* A GeoJsonObject is the base object of GeospatialSwift functionality
* Bounding Box generated from any GeoJsonObject
* GeoJson generated from any GeoJsonObject

### GeoJsonObjects

* Minimum distance to a given point (Optional error distance)
* Contains a given point (Optional error distance)
* Bounding box
* GeoJson as a Dictionary
* Points array which make up the geometry
* GeodesicPoint with SimplePoint implementation
* GeodesicLineSegment with midpoint and bearing functions

* Point
  * Normalize
* MultiPoint
* LineString
  * Length
* MultiLineString
  * Length
* Polygon
  * Centroid
  * Area
* MultiPolygon
  * Area
* GeometryCollection
* Feature
* FeatureCollection

### Geohash

Geospatial.geohash

* Find the geohash of any coordinate
* Find the center coordinate of any geohash
* Find all 9 neighboring geohash given a coordinate
* Create a bounding box (GeohashBox) from a geohash

### WKT - Not Fully Supported

Geospatial.parse(wkt: String) -> GeoJsonObject

* Minimal WKT parsing support which transforms to a GeoJsonObject.
* POINT, LINESTRING, MULTILINESTRING, POLYGON, MULTPOLYGON.
* This is currently only intended to parse a very simple WKT string

