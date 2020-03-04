internal extension Array {
    private var nilIfEmpty: Array? { isEmpty ? nil : self }
    
    var tail: Array? { Array(dropFirst()).nilIfEmpty }
    
    @inlinable mutating func appendChainable(_ newElement: Element) -> Self {
        append(newElement)
        return self
    }
    
    func at(_ index: Int) -> Element? {
        return self.isAccessible(at: index) ? self[index] : nil
    }
    
    func isAccessible(at index: Int) -> Bool {
        return index >= 0 && index <= count - 1
    }
    
}
