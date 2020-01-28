extension Result {
    var succeeded: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
    
    var failed: Bool { !succeeded }
    
    var success: Success? {
        switch self {
        case .success(let success): return success
        case .failure: return nil
        }
    }
    
    var failure: Failure? {
        switch self {
        case .success: return nil
        case .failure(let failure): return failure
        }
    }
}
