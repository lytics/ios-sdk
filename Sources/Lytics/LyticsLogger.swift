//
//  LyticsLogger.swift
//
//  Created by Mathew Gacy on 9/12/22.
//

import Foundation
import os.log

/// The various log levels that the Lytics SDK provides.
public enum LogLevel: Comparable, Equatable, Sendable {
    case debug
    case info
    case error

    /// Syslog numerical code.
    ///
    /// See [RFC 5424](https://www.rfc-editor.org/rfc/rfc5424#section-6.2.1).
    var code: Int {
        switch self {
        case .debug: return 7
        case .info: return 6
        case .error: return 3
        }
    }

    /// Returns a Boolean value indicating whether the value of the first argument is less than that of the second argument.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.code < rhs.code
    }
}

/// An object for writing interpolated messages to the logging system.
@usableFromInline
struct LyticsLogger: Sendable {
    var logLevel: LogLevel? = .error
    var log: @Sendable (OSLogType, @escaping () -> String, StaticString, StaticString, UInt) -> Void

    /// Log a debug message.
    /// - Parameter message: The message to log.
    @usableFromInline
    func debug(
        _ message: @autoclosure @escaping () -> String,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        guard shouldLog(.debug) else {
            return
        }
        log(.debug, message, file, function, line)
    }

    /// Log an info message.
    /// - Parameter message: The message to log.
    @usableFromInline
    func info(
        _ message: @autoclosure @escaping () -> String,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        guard shouldLog(.info) else {
            return
        }
        log(.info, message, file, function, line)
    }

    /// Log an error message.
    /// - Parameter message: The message to log.
    @usableFromInline
    func error(
        _ message: @autoclosure @escaping () -> String,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        guard shouldLog(.error) else {
            return
        }
        log(.error, message, file, function, line)
    }

    private func shouldLog(_ level: LogLevel) -> Bool {
        guard let logLevel else {
            return false
        }

        return logLevel >= level
    }
}

extension LyticsLogger {
    static func makeOSLog(logLevel: LogLevel, subsystem: String, category: String) -> Self {
        let logger = OSLog(subsystem: subsystem, category: category)

        return LyticsLogger(
            logLevel: logLevel,
            log: { _, message, file, function, line in
                logger.callAsFunction("\(file) \(function):\(line) - \(message())")
            }
        )
    }

    @available(iOS 14.0, *)
    static func makeLogger(logLevel: LogLevel, subsystem: String, category: String) -> Self {
        let logger = Logger(subsystem: subsystem, category: category)

        return LyticsLogger(
            logLevel: logLevel,
            log: { logLevel, message, file, function, line in
                logger.log(level: logLevel, "\(file) \(function):\(line) - \(message())")
            }
        )
    }

    static var live: Self {
        let logLevel = LogLevel.error
        let subsystem = "com.lytics.sdk"
        let category = ""

        if #available(iOS 14.0, *) {
            return makeLogger(logLevel: logLevel, subsystem: subsystem, category: category)
        } else {
            return makeOSLog(logLevel: logLevel, subsystem: subsystem, category: category)
        }
    }
}
