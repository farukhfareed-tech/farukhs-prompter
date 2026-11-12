import SwiftUI

struct Script: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var body: String
    var tag: String = "Draft"
    var updated = Date()

    /// Words you actually say (cue markers like [pause] are not counted).
    var wordCount: Int {
        let clean = body.replacingOccurrences(of: "\\[[^\\]]*\\]", with: " ", options: .regularExpression)
        return clean.split(whereSeparator: { $0.isWhitespace }).count
    }

    /// Read time at a relaxed 150 words per minute.
    var readTime: String {
        let seconds = Double(wordCount) / 150.0 * 60.0
        if seconds < 60 { return "\(Int(seconds.rounded())) sec" }
        return String(format: "%.1f min", seconds / 60.0)
    }

    var paragraphs: [String] {
        body.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var preview: String {
        body.replacingOccurrences(of: "\\[[^\\]]*\\]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\n", with: " ")
    }
}

enum Segment {
    case text(String)
    case cue(String)
}

/// Splits a line into normal text and cue markers such as [pause].
func segments(of s: String) -> [Segment] {
    var out: [Segment] = []
    var buffer = ""
    var i = s.startIndex
    while i < s.endIndex {
        if s[i] == "[", let close = s[i...].firstIndex(of: "]") {
            if !buffer.isEmpty { out.append(.text(buffer)); buffer = "" }
            out.append(.cue(String(s[s.index(after: i)..<close])))
            i = s.index(after: close)
        } else {
            buffer.append(s[i])
            i = s.index(after: i)
        }
    }
    if !buffer.isEmpty { out.append(.text(buffer)) }
    return out
}

/// Saves scripts as a file in the app's own storage. Nothing leaves the phone.
final class ScriptStore: ObservableObject {
    @Published var scripts: [Script] = [] { didSet { save() } }

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("scripts.json")
    }

    init() {
        if let data = try? Data(contentsOf: fileURL),
           let saved = try? JSONDecoder().decode([Script].self, from: data), !saved.isEmpty {
            scripts = saved
        } else {
            scripts = ScriptStore.samples
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(scripts) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    func add() -> UUID {
        let s = Script(title: "Untitled script", body: "")
        scripts.insert(s, at: 0)
        return s.id
    }

    func delete(at offsets: IndexSet, in visible: [Script]) {
        let ids = offsets.map { visible[$0].id }
        scripts.removeAll { ids.contains($0.id) }
    }

    static let samples: [Script] = [
        Script(title: "Morning vlog opener", body: "Good morning, everyone. [smile]\n\nToday I'm trying something I've been putting off for weeks, and I think you'll be surprised by how it turns out.\n\nBefore we start, grab a coffee. [pause] This one takes a few minutes.\n\nHere is the plan. First, I'll show you what I started with. Then we'll go step by step, and I'll tell you everything that went wrong along the way. [slow]\n\nBy the end, you'll know exactly what to do, and what to skip.\n\nLet's get into it.", tag: "Intro"),
        Script(title: "Phone review, week two", body: "I've used this phone for two weeks. [pause] Here is what I actually think.\n\nThe camera is the headline, and it earns it. Low light is clean, skin tones look natural, and video stays steady even when I'm walking.\n\nBattery gets me through a full day with room to spare. [smile]\n\nThe one thing I'd change is the speaker. It's fine, but it's not great.", tag: "Review")
    ]
}
