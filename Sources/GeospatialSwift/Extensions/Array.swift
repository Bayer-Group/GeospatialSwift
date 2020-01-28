internal extension Array {
    private var nilIfEmpty: Array? { isEmpty ? nil : self }
    
    var tail: Array? { Array(dropFirst()).nilIfEmpty }
    
    @inlinable mutating func appendChainable(_ newElement: Element) -> Self {
        append(newElement)
        return self
    }
}
