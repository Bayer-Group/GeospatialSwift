import Foundation

protocol LoggerProtocol {
    func writeToLog(_ message: @autoclosure () -> String, _ file: String, _ function: String, _ line: Int, logLevel: LogLevel)
}

extension LoggerProtocol {
    func debug(_ message: @autoclosure () -> String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        return self.writeToLog(message, file, function, line, logLevel: .debug)
    }
    
    func info(_ message: @autoclosure () -> String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        return self.writeToLog(message, file, function, line, logLevel: .info)
    }
    
    func warning(_ message: @autoclosure () -> String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        return self.writeToLog(message, file, function, line, logLevel: .warning)
    }
    
    func error(_ message: @autoclosure () -> String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        return self.writeToLog(message, file, function, line, logLevel: .error)
    }
}

internal struct Logger: LoggerProtocol {
    private let minimumLogLevelShown: LogLevel
    private let applicationPrefix: String
    private let emojisForLogLevels: [String] = ["", "💙", "💚", "💛", "❤️", "💜"]
    
    init(applicationPrefix: String, minimumLogLevelShown: LogLevel) {
        self.minimumLogLevelShown = minimumLogLevelShown
        self.applicationPrefix = applicationPrefix
    }
    
    func writeToLog(_ message: @autoclosure () -> String, _ file: String, _ function: String, _ line: Int, logLevel: LogLevel) {
        if minimumLogLevelShown.rawValue <= logLevel.rawValue {
            let fileNsString = ((file as NSString).lastPathComponent as NSString)
            print("\(applicationPrefix) \(colorizeString("\(fileNsString.deletingPathExtension).\(fileNsString.pathExtension):\(line) \(function):", colorId: 0))", terminator: "")
            print(" \(colorizeString(message, colorId: logLevel.rawValue))\n", terminator: "")
        }
    }
    
    private func colorizeString(_ message: @autoclosure () -> String, colorId: Int) -> String {
        return "\(emojisForLogLevels[colorId])\(message())\(emojisForLogLevels[colorId])"
    }
}

public enum LogLevel: Int {
    case debug = 1
    case info
    case warning
    case error
    case none
    
    var name: String {
        switch self {
        case .debug: return "Debug"
        case .info: return "Info"
        case .warning: return "Warning"
        case .error: return "Error"
        case .none: return "None"
        }
    }
}
