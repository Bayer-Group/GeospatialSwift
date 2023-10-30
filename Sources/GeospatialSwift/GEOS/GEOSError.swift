//
//  GEOSError.swift
//  GeospatialSwift
//
//  Created by Nickola Andriiev on 30/10/2023.
//

import Foundation

public enum GEOSError: Error, Hashable, Sendable {
    case unableToCreateContext
    case libraryError(errorMessages: [String])
    case wkbDataWasEmpty
    case typeMismatch(actual: GEOSObjectType?, expected: GEOSObjectType)
    case noMinimumBoundingCircle
}
