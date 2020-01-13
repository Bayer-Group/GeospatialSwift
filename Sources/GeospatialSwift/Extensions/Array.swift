internal extension Array {
    var nilIfEmpty: Array? { isEmpty ? nil : self }
    
    var tail: Array? { Array(dropFirst()).nilIfEmpty }
}
