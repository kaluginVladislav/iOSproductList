//
//  Log.swift
//  Activity
//
//  Created by Spitsin Sergey on 24.05.2020.
//  Copyright © 2020 ActivityIT. All rights reserved.
//

import os.log
import Foundation

extension Log {

    /**
    Log level used in Log logger.
    - `All`:     Log with any level will be logged out
    - `Default`: Log out string with level greate than or equal to default
    - `Debug`:   Log out string with level greate than or equal to debug
    - `Info`:    Log out string with level greate than or equal to info
    - `Error`:   Log out string with level greate than or equal to error
    - `Fault`:   Log out string with level greate than or equal to fault
    - `Off`:     Log is turned off
    */
    public enum Level: Int, Comparable {

        case all        = 0

        case `default`  = 1

        case debug      = 2

        case info       = 3

        case error      = 4

        case fault      = 5

        case off        = 6

        /// String description for log level.
        public var descrition: String {
            switch self {
            case .default:
                return "Default"
            case .debug:
                return "Debug"
            case .info:
                return "Info"
            case .error:
                return "Error"
            case .fault:
                return "Fault"
            default:
                assertionFailure("Invalid level")

                return "Null"
            }
        }

        @available(iOS 10.0, macOS 10.12, *)
        public var osLogType: OSLogType {
            switch self {
            case .default:
                return .default
            case .debug:
                return .debug
            case .info:
                return .info
            case .error:
                return .error
            case .fault:
                return .fault
            default:
                assertionFailure("Invalid level")

                return .default
            }
        }

        static public func < (lhs: Level, rhs: Level) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        static public func <= (lhs: Level, rhs: Level) -> Bool {
            return lhs.rawValue <= rhs.rawValue
        }

        static public func >= (lhs: Level, rhs: Level) -> Bool {
            return lhs.rawValue >= rhs.rawValue
        }
    }
}

extension Log {

    /**
    Log output used in Log logger.
    - `debugger`: Log out string in xcode debug
    - `device`: Log out string in device
    - `file`:   Log out string in file
    */
    public enum Output: String {

        case debugger

        case device

        case file

    }
}

public final class Log {

    // MARK: Instance

    /// Default logger instance.
    public static let shared = Log()

    private init() { }


    // MARK: Public property

    /// Whether should show date & time field, true for showing, false for hidding.
    public var showDateTime = true

    /// Whether should show process info, true for showing, false for hidding.
    public var showProcessInfo = true

    /// Whether should show log level field, true for showing, false for hidding.
    public var showLevel = true

    /// Whether should show file name field, true for showing, false for hidding.
    public var showFileName = true

    /// Whether should show line number field, true for showing, false for hidding.
    public var showLineNumber = true

    /// Whether should show function name field, true for showing, false for hidding.
    public var showFunctionName = true

    /// Whether should show thread info, true for showing, false for hidding.
    public var showThreadInfo = true

    /// Whether should save mssages in immediately, true for enable, false for disable.
    public var appendMessagesToFileImmediately = false

    /// NSDateFromatter used internally.
    public var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()

        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "y-MM-dd HH:mm:ss.SSSSSSZ"

        return dateFormatter
    }()

    /// Log level current used.
    #if DEBUG
    public var level: Log.Level = .all
    #else
    public var level: Log.Level = .error
    #endif

    #if DEBUG
    public var outputs: [Log.Output] = [.debugger, .file]
    #else
    public var outputs: [Log.Output] = [.device, .file]
    #endif

    /**
    Print an new line, without any fileds. This will ignore any filed settings.
    */
    @discardableResult public func emptyLine() -> String {
        return log("")
    }

    /**
    Print an new line, without any fileds. This will ignore any filed settings.
    */
    @discardableResult public static func emptyLine() -> String {
        return Log.shared.emptyLine()
    }

    /**
    Logs textual representation of `value` with default level.
    
    - parameter value:    A value conforms `Streamable`, `Printable`, `DebugPrintable`.
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public func `default`<T>(_ value: T, function: String = #function, file: String = #file, line: Int = #line, threaded: Bool = false) -> String? {
        return `default`("\(value)", function: function, file: file, line: line, threaded: threaded)
    }

    /**
    Logs textual representation of `value` with default level.
    
    - parameter value:    A value conforms `Streamable`, `Printable`, `DebugPrintable`.
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public static func `default`<T>(_ value: T, function: String = #function, file: String = #file, line: Int = #line, threaded: Bool = false) -> String? {
        return Log.shared.default(value, function: function, file: file, line: line, threaded: threaded)
    }

    /**
    Logs an message with formatted string and arguments list with default level.
    
    - parameter format:   Formatted string
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack

    - returns: The string logged out.
    */
    @discardableResult public func `default`(_ format: String = "", function: String = #function, file: String = #file, line: Int = #line, args: CVarArg..., threaded: Bool = false) -> String? {
        if .default >= level {
            return log(.default, function: function, file: file, line: line, format: format, args: args, threaded: threaded)
        }

        return nil
    }

    /**
    Logs an message with formatted string and arguments list with default level.
    
    - parameter format:   Formatted string
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public static func `default`(_ format: String = "", function: String = #function, file: String = #file, line: Int = #line, args: [CVarArg], threaded: Bool = false) -> String? {
        return Log.shared.default(format, function: function, file: file, line: line, args: args, threaded: threaded)
    }

    /**
    Logs textual representation of `value` with debug level.
    
    - parameter value:    A value conforms `Streamable`, `Printable`, `DebugPrintable`.
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public func debug<T>(_ value: T, function: String = #function, file: String = #file, line: Int = #line, threaded: Bool = false) -> String? {
        return debug("\(value)", function: function, file: file, line: line, threaded: threaded)
    }

    /**
    Logs textual representation of `value` with debug level.
    
    - parameter value:    A value conforms `Streamable`, `Printable`, `DebugPrintable`.
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public static func debug<T>(_ value: T, function: String = #function, file: String = #file, line: Int = #line, threaded: Bool = false) -> String? {
        return Log.shared.debug(value, function: function, file: file, line: line, threaded: threaded)
    }

    /**
    Logs an message with formatted string and arguments list with debug level.
    
    - parameter format:   Formatted string
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public func debug(_ format: String = "", function: String = #function, file: String = #file, line: Int = #line, args: CVarArg..., threaded: Bool = false) -> String? {
        if .debug >= level {
            return log(.debug, function: function, file: file, line: line, format: format, args: args, threaded: threaded)
        }
        return nil
    }

    /**
    Logs an message with formatted string and arguments list with debug level.
    
    - parameter format:   Formatted string
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public static func debug(_ format: String = "", function: String = #function, file: String = #file, line: Int = #line, args: [CVarArg], threaded: Bool = false) -> String? {
        return Log.shared.debug(format, function: function, file: file, line: line, args: args, threaded: threaded)
    }

    /**
    Logs textual representation of `value` with info level.
    
    - parameter value:    A value conforms `Streamable`, `Printable`, `DebugPrintable`.
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public func info<T>(_ value: T, function: String = #function, file: String = #file, line: Int = #line, threaded: Bool = false) -> String? {
        return info("\(value)", function: function, file: file, line: line, threaded: threaded)
    }

    /**
    Logs textual representation of `value` with info level.
    
    - parameter value:    A value conforms `Streamable`, `Printable`, `DebugPrintable`.
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter threaded: Thread call stack

    - returns: The string logged out.
    */
    @discardableResult public static func info<T>(_ value: T, function: String = #function, file: String = #file, line: Int = #line, threaded: Bool = false) -> String? {
        return Log.shared.info(value, function: function, file: file, line: line, threaded: threaded)
    }

    /**
    Logs an message with formatted string and arguments list with info level.
    
    - parameter format:   Formatted string
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public func info(_ format: String = "", function: String = #function, file: String = #file, line: Int = #line, args: CVarArg..., threaded: Bool = false) -> String? {
        if .info >= level {
            return log(.info, function: function, file: file, line: line, format: format, args: args, threaded: threaded)
        }
        return nil
    }

    /**
    Logs an message with formatted string and arguments list with info level.
    
    - parameter format:   Formatted string
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public static func info(_ format: String = "", function: String = #function, file: String = #file, line: Int = #line, args: [CVarArg], threaded: Bool = false) -> String? {
        return Log.shared.info(format, function: function, file: file, line: line, args: args, threaded: threaded)
    }

    /**
    Logs textual representation of `value` with error level.
    
    - parameter value:    A value conforms `Streamable`, `Printable`, `DebugPrintable`.
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public func error<T>(_ value: T, function: String = #function, file: String = #file, line: Int = #line, threaded: Bool = false) -> String? {
        return error("\(value)", function: function, file: file, line: line, threaded: threaded)
    }

    /**
    Logs textual representation of `value` with error level.
    
    - parameter value:    A value conforms `Streamable`, `Printable`, `DebugPrintable`.
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public static func error<T>(_ value: T, function: String = #function, file: String = #file, line: Int = #line, threaded: Bool = false) -> String? {
        return Log.shared.error(value, function: function, file: file, line: line, threaded: threaded)
    }

    /**
    Logs an message with formatted string and arguments list with error level.
    
    - parameter format:   Formatted string
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public func error(_ format: String = "", function: String = #function, file: String = #file, line: Int = #line, args: CVarArg..., threaded: Bool = false) -> String? {
        if .error >= level {
            return log(.error, function: function, file: file, line: line, format: format, args: args, threaded: threaded)
        }
        return nil
    }

    /**
    Logs an message with formatted string and arguments list with error level.
    
    - parameter format:   Formatted string
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public static func error(_ format: String = "", function: String = #function, file: String = #file, line: Int = #line, args: [CVarArg], threaded: Bool = false) -> String? {
        return Log.shared.error(format, function: function, file: file, line: line, args: args, threaded: threaded)
    }

    /**
    Logs textual representation of `fault` with error level.

    - parameter value:    A value conforms `Streamable`, `Printable`, `DebugPrintable`.
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter threaded: Thread call stack

    - returns: The string logged out.
    */
    @discardableResult public func fault<T>(_ value: T, function: String = #function, file: String = #file, line: Int = #line, threaded: Bool = false) -> String? {
        return fault("\(value)", function: function, file: file, line: line, threaded: threaded)
    }

    /**
    Logs textual representation of `fault` with error level.

    - parameter value:    A value conforms `Streamable`, `Printable`, `DebugPrintable`.
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter threaded: Thread call stack

    - returns: The string logged out.
    */
    @discardableResult public static func fault<T>(_ value: T, function: String = #function, file: String = #file, line: Int = #line, threaded: Bool = false) -> String? {
        return Log.shared.error(value, function: function, file: file, line: line, threaded: threaded)
    }

    /**
    Logs an message with formatted string and arguments list with fault level.

    - parameter format:   Formatted string
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack

    - returns: The string logged out.
    */
    @discardableResult public func fault(_ format: String = "", function: String = #function, file: String = #file, line: Int = #line, args: CVarArg..., threaded: Bool = false) -> String? {
        if .fault >= level {
            return log(.fault, function: function, file: file, line: line, format: format, args: args, threaded: threaded)
        }
        return nil
    }

    /**
    Logs an message with formatted string and arguments list with fault level.

    - parameter format:   Formatted string
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack

    - returns: The string logged out.
    */
    @discardableResult public static func fault(_ format: String = "", function: String = #function, file: String = #file, line: Int = #line, args: [CVarArg], threaded: Bool = false) -> String? {
        return Log.shared.fault(format, function: function, file: file, line: line, args: args, threaded: threaded)
    }

    /**
    Logs an message with formatted string and arguments list.
    
    - parameter level:    Log level
    - parameter format:   Formatted string
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public func logWithLevel(_ level: Log.Level, _ format: String = "", function: String = #function, file: String = #file, line: Int = #line, args: CVarArg..., threaded: Bool = false) -> String? {
        if level >= level {
            return log(level, function: function, file: file, line: line, format: format, args: args, threaded: threaded)
        }
        return nil
    }

    /**
    Logs an message with formatted string and arguments list.
    
    - parameter level:    Log level
    - parameter format:   Formatted string
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult public static func logWithLevel(_ level: Log.Level, _ format: String = "", function: String = #function, file: String = #file, line: Int = #line, args: CVarArg..., threaded: Bool = false) -> String? {
        return Log.shared.logWithLevel(level, format, function: function, file: file, line: line, args: args, threaded: threaded)
    }

    /**
    Construct a log message, log it out and return it.
    
    - parameter level:    Log level
    - parameter function: Function name
    - parameter file:     File name
    - parameter line:     Line number
    - parameter format:   Formatted string
    - parameter args:     Arguments list
    - parameter threaded: Thread call stack
    
    - returns: The string logged out.
    */
    @discardableResult fileprivate func log(_ level: Log.Level, function: String = #function, file: String = #file, line: Int = #line, format: String, args: [CVarArg], threaded: Bool) -> String {
        let dateTime = showDateTime ? "\(dateFormatter.string(from: Date())) " : ""

        var processInfoString =  ""

        if showProcessInfo {
            let processInfo = ProcessInfo()

            var threadID: UInt64 = 0
            pthread_threadid_np(nil, &threadID)

            processInfoString = "\(processInfo.processName)[\(getpid()):\(threadID)] "
        }

        let levelString = showLevel ? "[\(level.descrition)] " : ""

        var fileLine = ""

        if showFileName {
            fileLine += "[" + (file as NSString).lastPathComponent

            if showLineNumber {
                fileLine += ":\(line)"
            }

            fileLine += "] "
        }

        let functionString = showFunctionName ? function : ""

        let message: String

        if args.isEmpty {
            message = format
        } else {
            message = String(format: format, arguments: args)
        }

        var threadInfo = ""

        if showThreadInfo, threaded {
            threadInfo += "\n\n" + "*Thread and Operation Queue info:* \n\(Thread.current)"

            if let operationQueue = OperationQueue.current {
                threadInfo += "\n\(operationQueue)"
            }

            threadInfo += "\n\n" + "*Thread call stack symbols:* \n\(Thread.callStackSymbols.joined(separator: "\n"))\n"
        }

        func preparedLogString(withDate: Bool = true) -> String {
            let infoString = (withDate ? "\(dateTime)" : "") + "\(processInfoString)\(levelString)\(fileLine)\(functionString)".trimmingCharacters(in: CharacterSet(charactersIn: " "))
            let logString = infoString + (infoString.isEmpty ? "" : ": ") + "\(message)\(threadInfo)"

            return logString
        }

        for output in outputs {
            switch output {
            case .file:
                let message = preparedLogString()

                LogFileManager.shared.appendMessageToMemory(message)

                if appendMessagesToFileImmediately {
                    LogFileManager.shared.appendMessageToFile(message)
                }
            case .device:
                if #available(iOS 10.0, macOS 10.12, *) {
                    os_log("%@", type: level.osLogType, preparedLogString(withDate: false))
                } else {
                    NSLog("%@", preparedLogString(withDate: false))
                }
            case .debugger:
                print(preparedLogString())
            }
        }

        return preparedLogString()
    }

    @discardableResult fileprivate func log(_ message: String) -> String {
        for output in outputs {
            switch output {
            case .file:
                LogFileManager.shared.appendMessageToMemory(message)

                if appendMessagesToFileImmediately {
                    LogFileManager.shared.appendMessageToFile(message)
                }
            case .device:
                if #available(iOS 10.0, macOS 10.12, *) {
                    os_log("%@", type: .default, message)
                } else {
                    NSLog("%@", message)
                }
            case .debugger:
                print(message)
            }
        }

        return message
    }
}
