internal extension Array {
    var tail: Array? {
        let tail = Array(dropFirst())
        if tail.isEmpty { return nil }
        return tail
    }
}
