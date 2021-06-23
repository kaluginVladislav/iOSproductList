//
//  LogFileManager.swift
//  Activity
//
//  Created by Spitsin Sergey on 24.05.2020.
//  Copyright © 2020 ActivityIT. All rights reserved.
//

import Foundation

/// File Manager for store logs in coded format
public final class LogFileManager {

    // MARK: Instance

    /// Default log file manager instance.
    public static let shared = LogFileManager()

    private init() { }


    // MARK: Private property

    private let serialQueue = DispatchQueue(label: "Log serial queue")

    private var messages: [String] = []


    // MARK: Public property

    public var fileName = "Logs"

    public var fileExtension = "txt"

    public var fileLogsCount = 1000

    // MARK: Public methods

    public func getFileURL() throws -> URL {
        do {
            let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

            return directory.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
        } catch {
            let userInfo: [String: Any] = [
                NSLocalizedDescriptionKey: NSLocalizedString("log.url.description", value: "Unable to get file URL", comment: ""),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("log.url.failure.reason", value: "URL is nil", comment: ""),
                NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("log.url.recovery.suggestion", value: "Set file URL", comment: "")
            ]

            throw NSError(domain: "LogErrorDomain", code: 2001, userInfo: userInfo)
         }
    }

    public func getMemoryData() throws -> Data {
        return try getData(messages)
    }

    public func getFileData() throws -> Data {
        let messages = try getFileMessages()

        return try getData(messages)
    }

    public func getData(_ messages: [String]) throws -> Data {
        var messagesData = Data()

        for message in messages {
            if let data = (message + "\n").data(using: .utf8) {
                messagesData.append(data)
            } else {
                let userInfo: [String: Any] = [
                    NSLocalizedDescriptionKey: NSLocalizedString("log.converter.description", value: "Unable to convert utf8 data from message", comment: ""),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString("log.converter.failure.reason", value: "Invalid message", comment: ""),
                    NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("log.converter.recovery.suggestion", value: "Try another message", comment: "")
                ]

                throw NSError(domain: "LogErrorDomain", code: 2002, userInfo: userInfo)
            }
        }

        return messagesData
    }

    public func getFileMessages() throws -> [String] {
        let url = try self.getFileURL()

        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()

        let messages = try decoder.decode([String].self, from: data)

        return messages
    }

    public func removeMessagesFromMemory() {
        self.messages.removeAll()
    }

    public func appendMessageToMemory(_ message: String) {
        appendMessagesToMemory([message])
    }

    public func appendMessagesToMemory(_ messages: [String]) {
        for message in messages {
            self.messages.append(message)

            if self.messages.count > fileLogsCount {
                self.messages.removeFirst()
            }
        }
    }

    public func setMessageToMemory(_ message: String) {
        setMessagesToMemory([message])
    }

    public func setMessagesToMemory(_ messages: [String]) {
        self.messages.removeAll()

        for message in messages {
            self.messages.append(message)

            if self.messages.count > fileLogsCount {
                return
            }
        }
    }

    public func insertMessageToMemory(_ message: String, at index: Int) {
        insertMessagesToMemory([message], at: index)
    }

    public func insertMessagesToMemory(_ messages: [String], at index: Int) {
        for message in messages {
            self.messages.insert(message, at: index)

            if self.messages.count > fileLogsCount {
                return
            }
        }
    }

    public func removeMessagesFromFile(completion: ((Result<Void, Error>) -> Void)? = nil) {
        serialQueue.async {
            do {
                let url = try self.getFileURL()

                self.remove(fileWithURL: url, completion: completion)
            } catch let error {
                completion?(.failure(error))
            }
        }
    }

    public func appendMessagesFromFileToMemory(completion: ((Result<[String], Error>) -> Void)? = nil) {
        serialQueue.async {
            do {
                let messages: [String] = try self.getFileMessages().reversed()

                self.appendMessagesToMemory(messages)

                completion?(.success(messages))
            } catch let error {
                completion?(.failure(error))
            }
        }
    }

    public func setMessagesFromFileToMemory(completion: ((Result<[String], Error>) -> Void)? = nil) {
        serialQueue.async {
            do {
                let messages: [String] = try self.getFileMessages()

                self.setMessagesToMemory(messages)

                completion?(.success(messages))
            } catch let error {
                completion?(.failure(error))
            }
        }
    }

    public func insertMessagesFromFileToMemory(at index: Int, completion: ((Result<[String], Error>) -> Void)? = nil) {
        serialQueue.async {
            do {
                let messages: [String] = try self.getFileMessages().reversed()

                self.insertMessagesToMemory(messages, at: index)

                completion?(.success(messages))
            } catch let error {
                completion?(.failure(error))
            }
        }
    }

    public func appendMessagesFromMemoryToFile(completion: ((Result<Void, Error>) -> Void)? = nil) {
        self.appendMessagesToFile(self.messages, completion: completion)
    }

    public func setMessagesFromMemoryToFile(completion: ((Result<Void, Error>) -> Void)? = nil) {
        self.setMessagesToFile(self.messages, completion: completion)
    }

    public func insertMessagesFromMemoryToFile(at index: Int, completion: ((Result<Void, Error>) -> Void)? = nil) {
        self.insertMessagesToFile(self.messages, at: index, completion: completion)
    }

    public func appendMessageToFile(_ message: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        appendMessagesToFile([message], completion: completion)
    }

    public func appendMessagesToFile(_ messages: [String], completion: ((Result<Void, Error>) -> Void)? = nil) {
        serialQueue.async {
            do {
                let url = try self.getFileURL()

                var currentFileMessages = (try? self.getFileMessages()) ?? []

                currentFileMessages.append(contentsOf: messages)

                while currentFileMessages.count > self.fileLogsCount {
                    currentFileMessages.removeFirst()
                }

                self.remove(fileWithURL: url) { [weak self] (result) in
                    guard let self = self else { return }

                    self.append(currentFileMessages, toFileWithURL: url, completion: completion)
                }
            } catch let error {
                completion?(.failure(error))
            }
        }
    }

    public func setMessageToFile(_ message: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        setMessagesToFile([message], completion: completion)
    }

    public func setMessagesToFile(_ messages: [String], completion: ((Result<Void, Error>) -> Void)? = nil) {
        serialQueue.async {
            do {
                let url = try self.getFileURL()

                self.remove(fileWithURL: url) { [weak self] (result) in
                    guard let self = self else { return }

                    self.append(messages, toFileWithURL: url, completion: completion)
                }
            } catch let error {
                completion?(.failure(error))
            }
        }
    }

    public func insertMessageToFile(_ message: String, at index: Int, completion: ((Result<Void, Error>) -> Void)? = nil) {
        insertMessagesToFile([message], at: index, completion: completion)
    }

    public func insertMessagesToFile(_ messages: [String], at index: Int, completion: ((Result<Void, Error>) -> Void)? = nil) {
        serialQueue.async {
            do {
                let url = try self.getFileURL()

                var currentFileMessages = (try? self.getFileMessages()) ?? []

                currentFileMessages.insert(contentsOf: messages, at: index)

                while currentFileMessages.count > self.fileLogsCount {
                    currentFileMessages.removeFirst()
                }

                self.remove(fileWithURL: url) { [weak self] (result) in
                    guard let self = self else { return }

                    self.append(currentFileMessages, toFileWithURL: url, completion: completion)
                }
            } catch let error {
                completion?(.failure(error))
            }
        }
    }

    // MARK: Private methods

    private func remove(fileWithURL url: URL, completion: ((Result<Void, Error>) -> Void)? = nil) {
        do {
            try FileManager.default.removeItem(at: url)

            completion?(.success(()))
        } catch let error {
            completion?(.failure(error))
        }
    }

    private func append(_ messages: [String], toFileWithURL url: URL, completion: ((Result<Void, Error>) -> Void)? = nil) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let encodedMessagesData = try encoder.encode(messages)

            try append(encodedMessagesData, toFileWithURL: url)

            completion?(.success(()))
        } catch let error {
            completion?(.failure(error))
        }
    }

    private func append(_ data: Data, toFileWithURL url: URL) throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }

        if let fileHandle = FileHandle(forWritingAtPath: url.path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        } else {
            let userInfo: [String: Any] = [
                NSLocalizedDescriptionKey: NSLocalizedString("log.fileHandle.description", value: "Unable to init FileHandle with: \(url)", comment: ""),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("log.fileHandle.failure.reason", value: "URL path is invalid", comment: ""),
                NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("log.fileHandle.recovery.suggestion", value: "Set valid URL path", comment: "")
            ]

            throw NSError(domain: "LogErrorDomain", code: 2003, userInfo: userInfo)
        }
    }
}
