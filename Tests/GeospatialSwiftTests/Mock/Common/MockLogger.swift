@testable import GeospatialSwift

final class MockLogger: LoggerProtocol {
    let logger = Logger(applicationPrefix: "Logger: ", minimumLogLevelShown: .debug)
    
    var writeToLogCount: Int = 0
    
    func writeToLog(_ message: @autoclosure () -> String, _ file: String, _ function: String, _ line: Int, logLevel: LogLevel) {
        logger.debug(message, file, function, line)
        
        writeToLogCount += 1
    }
}
