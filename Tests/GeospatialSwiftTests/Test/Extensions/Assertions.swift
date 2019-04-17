import XCTest

// swiftlint:disable identifier_name
public func AssertEqualAccuracy10(_ expression1: @autoclosure () -> Double, _ expression2: @autoclosure () -> Double, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(expression1(), expression2(), accuracy: 0.0000000001, file: file, line: line)
}

public func AssertEqualAccuracy6(_ expression1: @autoclosure () -> Double, _ expression2: @autoclosure () -> Double, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(expression1(), expression2(), accuracy: 0.000001, file: file, line: line)
}
// swiftlint:enable identifier_name
