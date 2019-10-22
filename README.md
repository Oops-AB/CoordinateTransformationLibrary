# CoordinateTransformationLibrary
 
RT90, SWEREF99 and WGS84 coordinate transformation library
 
This library is a Swift port of the Java library by Mathias Åhsberg. calculations are based entirely on the excellent javscript library by Arnold Andreassons.
 
Source: http://www.lantmateriet.se/geodesi/

Source: Arnold Andreasson, 2007. http://mellifica.se/konsult

Source: Björn Sållarp. 2009. http://blog.sallarp.com

Source: Mathias Åhsberg, 2009. http://github.com/goober/

## Usage

Include the coordinate transformation package in your project's `Package.swift` file.

```swift
import PackageDescription

let package = Package(
    name: "Project",
    dependencies: [
        .package (url: "https://github.com/Oops-AB/CoordinateTransformationLibrary.git", from: "1.0.0"),
    ],
    targets: [ ... ]
)
```
 
## Developer instructions

Import the coordinate transformation package:
```
import CoordinateTransformationLibrary
```

Create a position:
```
let position = RT90Position (x: 6583052, y: 1627548)
```

Convert to another kind of coordinates:
```
let wgsPos = position.toWGS84()
print ("latitude = \(wgsPos.latitude), longitude = \(wgsPos.longitude)")
```
