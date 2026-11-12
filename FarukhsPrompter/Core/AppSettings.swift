import SwiftUI

/// User preferences, saved automatically on the phone.
final class AppSettings: ObservableObject {
    private let d = UserDefaults.standard

    @Published var fontSize: Double { didSet { d.set(fontSize, forKey: "fontSize") } }
    @Published var speed: Double { didSet { d.set(speed, forKey: "speed") } }
    @Published var mirror: Bool { didSet { d.set(mirror, forKey: "mirror") } }
    @Published var showGuide: Bool { didSet { d.set(showGuide, forKey: "showGuide") } }
    @Published var countdown: Int { didSet { d.set(countdown, forKey: "countdown") } }
    @Published var accentChoice: AccentChoice { didSet { d.set(accentChoice.rawValue, forKey: "accent") } }

    var accent: Color { accentChoice.color }

    init() {
        fontSize = d.object(forKey: "fontSize") as? Double ?? 34
        speed = d.object(forKey: "speed") as? Double ?? 40
        mirror = d.bool(forKey: "mirror")
        showGuide = d.object(forKey: "showGuide") as? Bool ?? true
        countdown = d.object(forKey: "countdown") as? Int ?? 3
        accentChoice = AccentChoice(rawValue: d.string(forKey: "accent") ?? "") ?? .amber
    }
}
