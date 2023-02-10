//
//  TasksFromCode.swift
//  TodoCode
//
//  Created by Артeмий Шлесберг on 31/05/2019.
//  Copyright © 2019 Shlesberg. All rights reserved.
//

import Foundation
//import Highlightr

protocol TaskProtocol {
    var body: String {get}
    var context: ContextProtocol {get}
}

protocol ContextProtocol {
    var contextDescription: NSAttributedString {get}
    var fileURL: URL { get }
}

class FileNameContext: ContextProtocol {
    var contextDescription: NSAttributedString
    var fileURL: URL
    init(url: URL) {
        self.contextDescription = NSAttributedString(string: url.lastPathComponent)
        self.fileURL = url
    }
}

class SurroundingCodeContext: ContextProtocol {
    
    var contextDescription: NSAttributedString
    var fileURL: URL
    
    init(url: URL, code: String) {
        self.contextDescription = SurroundingCodeContext.highlighted(code: code)
        self.fileURL = url
    }
    
    static func highlighted(code: String) -> NSAttributedString{
        //TODO: highlight
//        let highlightr = Highlightr()!
//        highlightr.setTheme(to: "ocean")
//
//        let highlightedCode = highlightr.highlight(code, as: "swift")

        // this module depricated, use Code editor
        
//        return highlightedCode!
        return NSAttributedString(string: code)
    }
    
}
protocol TasksProtocol {
    func items() -> [TaskProtocol]
}


class FileSystemError: Error {
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

class SimpleTask: NSObject, TaskProtocol {
//    static func == (lhs: SimpleTask, rhs: SimpleTask) -> Bool {
//        return lhs.body == rhs.body && lhs.context.contextDescription == rhs.context.contextDescription
//    }
    
    
    var body: String
    var context: ContextProtocol

    public init(body: String, context: ContextProtocol) {
        self.body = body.capitalizingFirstLetter()
        self.context = context
        super.init()
    }
    
}

/// REcursively extracts all the '/TODO's from given path or url
class TasksFromCode: TasksProtocol {
    
    private var url: URL
    
    init(path: String) throws {
        guard let _url = URL(string: path) else {
            throw FileSystemError()
        }
        self.url = _url
    }
    
    init(url: URL) {
        self.url = url
    }
    
    func items() -> [TaskProtocol] {
        return recursivelyGetTodos(topURL: url)
    }
    
    let fileExtensions: [String] = ["swift", "py", "java", "js", "php"]
    
    private func recursivelyGetTodos(topURL: URL) -> [SimpleTask] {
        
        let fileManager = FileManager.default
        var tasks = [SimpleTask]()
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: topURL, includingPropertiesForKeys: nil)
            
            print("Contents of \(topURL.lastPathComponent):")
            print(fileURLs)
            
            for url in fileURLs {
                if url.pathExtension == "" {
                    tasks.append(contentsOf: recursivelyGetTodos(topURL: url))
                }
                if fileExtensions.contains(url.pathExtension) {
                    do {
                        let text2 = try String(contentsOf: url, encoding: .utf8)
                        let strings = text2.split(separator: "\n")
                        print(url.lastPathComponent)
                        print("strings count: \(strings.count)")
                        for (index,string) in strings.enumerated() {
                            if string.drop(while: { $0 == " "}).hasPrefix("//TODO:") {
                                let code =  strings.dropFirst(index - 2).dropLast(strings.count - index - 3).joined(separator: "\n")
                                tasks.append(SimpleTask(
                                    body: String(string.split(separator: ":").dropFirst().joined(separator: ":").drop(while: { $0 == " "})),
                                    context: SurroundingCodeContext(url: url, code: code)))
                            }
                        }
                        
                    } catch {
                        print(error)
                    }
                }
            }

        } catch {
            print("Error while enumerating files \(url): \(error.localizedDescription)")
        }
        return tasks
    }
    
}
