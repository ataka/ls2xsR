import Foundation
import ArgumentParser

struct Ls2XsR: ParsableCommand {
    @Argument()
    var path: String

    mutating func run() {
        let currentPath = FileManager.default.currentDirectoryPath
        guard let rootUrl = URL(string: currentPath)?.appendingPathComponent(path) else { fatalError("hoge") }

        var stringFiles: [String: LocalizableStringsFile] = [:]
        var baseLprojFiles: [BaseLprojFile] = []
        FileManager.default.fileURLs(in: rootUrl).forEach() { url in
            if let stringFile = LocalizableStringsFile(url: url) {
                stringFiles[stringFile.lang] = stringFile
            }
            if let baseLprojFile = BaseLprojFile(url: url) {
                baseLprojFiles.append(baseLprojFile)
            }
        }
//        print(stringFiles["ja"]!.url)
//        print(stringFiles["ja"]!.keyValues.map { "\($0.key) = \($0.value)" }.joined(separator: "\n"))
        baseLprojFiles.forEach { base in
            print("Base: \(base.url)")
            print("    [\(base.ibFiles.map(\.name).joined(separator: ", "))]")
        }
    }
}

Ls2XsR.main()

// MARK: - BaseLprojFile

final class BaseLprojFile {
    let url: URL

    init?(url: URL) {
        guard url.lastPathComponent == "Base.lproj" else { return nil }
        self.url = url
    }

    var ibFiles: [IbFile] {
        FileManager.default.fileURLs(in: url).compactMap {
            XibFile(url: $0) ?? StoryboardFile(url: $0)
        }
    }
}

// MARK: - IbFile

protocol IbFile {
    var url: URL { get }
    /// File name without  extension
    var name: String { get }
}

struct XibFile: IbFile {
    let url: URL
    let name: String

    init?(url: URL) {
        guard url.pathExtension == "xib" else { return nil }
        self.url = url
        name = url.deletingPathExtension().lastPathComponent
    }
}

struct StoryboardFile: IbFile {
    let url: URL
    let name: String

    init?(url: URL) {
        guard url.pathExtension == "storyboard" else { return nil }
        self.url = url
        name = url.deletingPathExtension().lastPathComponent
    }
}

// MARK: - LocalizableStringsFile

final class LocalizableStringsFile {
    typealias Key = String
    typealias Value = String

    let url: URL
    let lang: String
    private(set) var keyValues: [Key: Value]

    init?(url: URL) {
        let lang = url.deletingLastPathComponent().deletingPathExtension().lastPathComponent
        guard url.lastPathComponent == "Localizable.strings"
            && !lang.isEmpty,
            let keyValues = Self.readKeyValues(in: url) else { return nil }

        self.url = url
        self.lang = lang
        self.keyValues = keyValues
    }

    private static func readKeyValues(in url: URL) -> [Key: Value]? {
        guard let rawKeyValues = NSDictionary(contentsOf: url) as? [Key: Value] else { return nil }
        return rawKeyValues.mapValues { value in
            String(value.flatMap { (char: Character) -> [Character] in
                switch char {
                case "\n": return ["\\", "n"]
                case "\r": return ["\\", "r"]
                case "\\": return ["\\", "\\"]
                case "\"": return ["\\", "\""]
                default:   return [char]
                }
            })
        }
    }
}

// MARK: - FileManager

extension FileManager {
    func fileURLs(in url: URL) -> [URL] {
        let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [], options: .skipsHiddenFiles)

        var urls: [URL] = []
        while let url = enumerator?.nextObject() as? URL {
            urls.append(url)
        }
        return urls
    }
}
