# GeospatialSwift

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20Linux%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-green.svg?style=flat)](https://swift.org/package-manager/)

What is GeospatialSwift?

GeospatialSwift is an interface to translate a GeoJson document / dictionary into a swift object which fully conforms to the more recent [GeoJson specification - August 2016](https://tools.ietf.org/html/rfc7946).

A GeoJsonObject can be transformed to a bounding box.

## Features

* Unit tested with high coverage
* Ongoing development

## Installation

### Carthage

```github "MonsantoCo/GeospatialSwift" ~> 1.0.0```

### Package Manager

```.package(url: "git@github.com:MonsantoCo/GeospatialSwift.git", from: "1.0.0")```

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
* Bounding box for any shape
* GeoJson returned as a Dictionary
* Coordinates array for the associated geometry
* Line segments with midpoint and bearing functions

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

* Create a geohash from a coordinate or bounding box
* Get geohash neighbors (8)
* Create a bounding box for a geohash

### WKT - Not Fully Supported

Geospatial.parse(wkt: String) -> GeoJsonObject

* Minimal WKT parsing support which transforms to a GeoJsonObject.
* POINT, LINESTRING, MULTILINESTRING, POLYGON, MULTPOLYGON.
* This is currently only intended to parse a very simple WKT string

### Running GeospatialSwift in XCode
- Bootstrap Example: `rm -rf *.xcodeproj || rm -rf .build || swift package resolve && swift package generate-xcodeproj && open *.xcodeproj`
- In the Target  `GeospatialSwift`, select the tab `Signing & Capabilities` and check the box  `Automatically manage signing`
- In the scheme menu, select `Edit Scheme...`, select the `Test` item on the left, select the tab `Options`, and check the box `Gather coverage for "all targets"`
- In the target `GeospatialSwiftTests` select the tab `Build Phases` and add a `Run Script Phase` with the body `$PROJECT_DIR/Scripts/parrot.sh` and move the item to the top of the Buld Phases just below `Dependencies`.
- In the target `GeospatialSwift` select the tab `Build Phases` and add a `Run Script Phase` with the body `$PROJECT_DIR/Scripts/swiftlint.sh`.

## Extending GeospatialSwift in XCode

#### Option 1: Run with the current XCode project as is

#### Option 2: Rebuild it using `generate-xcodeproj`

- Setup: Package Manager Example: `rm -rf *.xcodeproj || rm -rf .build || swift package resolve && swift package generate-xcodeproj && open *.xcodeproj`
- Building: In the Target  `GeospatialSwift`, select the tab `Signing & Capabilities` and check the box  `Automatically manage signing`
- Code Coverage: In the scheme menu, select `Edit Scheme...`, select the `Test` item on the left, select the tab `Options`, and check the box `Gather coverage for "all targets"`
- Mocking: In the target `GeospatialSwiftTests` select the tab `Build Phases` and add a `Run Script Phase` with the body `$PROJECT_DIR/Scripts/parrot.sh` and move the item to the top of the Buld Phases just below `Dependencies`.
- Linting: In the target `GeospatialSwift` select the tab `Build Phases` and add a `Run Script Phase` with the body `$PROJECT_DIR/Scripts/swiftlint.sh`.
