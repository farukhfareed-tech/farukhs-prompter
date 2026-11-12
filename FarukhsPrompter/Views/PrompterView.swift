import SwiftUI
import UIKit

/// Drives the smooth scrolling, one frame at a time, in step with the screen.
final class PrompterEngine: NSObject, ObservableObject {
    @Published var offset: CGFloat = 0
    @Published var elapsed: TimeInterval = 0
    @Published var running = false

    var speed: CGFloat = 40          // points per second
    var maxOffset: CGFloat = 0

    private var link: CADisplayLink?
    private var last: CFTimeInterval = 0

    func start() {
        guard !running else { return }
        running = true
        last = CACurrentMediaTime()
        let l = CADisplayLink(target: self, selector: #selector(step))
        l.add(to: .main, forMode: .common)
        link = l
    }

    func pause() {
        link?.invalidate()
        link = nil
        running = false
    }

    func restart() {
        pause()
        offset = 0
        elapsed = 0
    }

    @objc private func step() {
        let now = CACurrentMediaTime()
        let dt = min(now - last, 0.1)
        last = now
        elapsed += dt
        offset = min(maxOffset, offset + speed * CGFloat(dt))
        if maxOffset > 0 && offset >= maxOffset { pause() }
    }

    deinit { link?.invalidate() }
}

private struct TextHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

struct PrompterView: View {
    let script: Script
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @StateObject private var engine = PrompterEngine()
    @State private var countdown: Int? = nil
    @State private var countdownTask: Task<Void, Never>? = nil
    @State private var dragStart: CGFloat? = nil

    private let guideFraction: CGFloat = 0.36

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { geo in
                ZStack(alignment: .top) {
                    textBlock
                        .offset(y: geo.size.height * guideFraction - engine.offset)

                    // Soft fade at the top and bottom of the reading area.
                    VStack(spacing: 0) {
                        LinearGradient(colors: [.black, .black.opacity(0)], startPoint: .top, endPoint: .bottom)
                            .frame(height: geo.size.height * 0.26)
                        Spacer()
                        LinearGradient(colors: [.black.opacity(0), .black], startPoint: .top, endPoint: .bottom)
                            .frame(height: geo.size.height * 0.30)
                    }
                    .allowsHitTesting(false)

                    if settings.showGuide {
                        Rectangle()
                            .fill(settings.accent.opacity(0.55))
                            .frame(height: 1)
                            .padding(.horizontal, 14)
                            .offset(y: geo.size.height * guideFraction)
                            .allowsHitTesting(false)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                .clipped()
                .contentShape(Rectangle())
                .gesture(scrubGesture)
            }
            .ignoresSafeArea()

            topBar
            controls

            if let c = countdown {
                ZStack {
                    Color.black.opacity(0.55).ignoresSafeArea()
                    Text("\(c)")
                        .font(.system(size: 160, weight: .ultraLight))
                        .foregroundColor(settings.accent)
                }
                .allowsHitTesting(false)
            }
        }
        .statusBarHidden(true)
        .onAppear {
            engine.speed = CGFloat(settings.speed)
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            countdownTask?.cancel()
            engine.pause()
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: settings.speed) { engine.speed = CGFloat($0) }
    }

    // MARK: Text

    private var textBlock: some View {
        VStack(spacing: 26) {
            ForEach(Array(script.paragraphs.enumerated()), id: \.offset) { _, p in
                paragraphText(p)
                    .font(.system(size: settings.fontSize, weight: .semibold))
                    .foregroundColor(Theme.fg)
                    .multilineTextAlignment(.center)
                    .lineSpacing(settings.fontSize * 0.22)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 28)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            GeometryReader { g in
                Color.clear.preference(key: TextHeightKey.self, value: g.size.height)
            }
        )
        .onPreferenceChange(TextHeightKey.self) { engine.maxOffset = $0 }
        .scaleEffect(x: settings.mirror ? -1 : 1, y: 1)
    }

    private func paragraphText(_ p: String) -> Text {
        segments(of: p).reduce(Text("")) { acc, seg in
            switch seg {
            case .text(let t):
                return acc + Text(t)
            case .cue(let c):
                return acc + Text(" \(c.uppercased()) ")
                    .font(.system(size: settings.fontSize * 0.42, weight: .semibold))
                    .foregroundColor(settings.accent)
            }
        }
    }

    // MARK: Gestures

    /// Drag the text up or down to move through the script while paused.
    private var scrubGesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { v in
                guard !engine.running else { return }
                if dragStart == nil { dragStart = engine.offset }
                let target = (dragStart ?? 0) - v.translation.height
                engine.offset = min(max(0, target), engine.maxOffset)
            }
            .onEnded { _ in dragStart = nil }
    }

    // MARK: Top bar

    private var progress: Double {
        engine.maxOffset > 0 ? Double(engine.offset / engine.maxOffset) : 0
    }

    private var wpm: Int {
        guard engine.elapsed > 3 else { return 0 }
        return Int(Double(script.wordCount) * progress / (engine.elapsed / 60))
    }

    private func clock(_ t: TimeInterval) -> String {
        let s = Int(t)
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    private var topBar: some View {
        VStack {
            HStack {
                Button { dismiss() } label: {
                    Label("Close", systemImage: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.fg)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1), in: Capsule())
                }
                Spacer()
                HStack(spacing: 14) {
                    Text("Time \(clock(engine.elapsed))")
                    Text("Pace \(wpm) wpm")
                }
                .font(.system(size: 12).monospacedDigit())
                .foregroundColor(Theme.muted)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .opacity(engine.running ? 0.35 : 1)
            Spacer()
        }
    }

    // MARK: Controls

    private var controls: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 14) {
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.line)
                        Capsule().fill(settings.accent).frame(width: g.size.width * progress)
                    }
                }
                .frame(height: 3)

                HStack(spacing: 14) {
                    Button(action: togglePlay) {
                        Image(systemName: engine.running || countdown != nil ? "pause.fill" : "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                            .frame(width: 62, height: 62)
                            .background(settings.accent, in: Circle())
                    }
                    .accessibilityLabel("Play or pause")

                    VStack(spacing: 2) {
                        labelRow("SPEED", "\(Int(settings.speed))")
                        Slider(value: $settings.speed, in: 10...120, step: 1)
                    }
                    VStack(spacing: 2) {
                        labelRow("SIZE", "\(Int(settings.fontSize))")
                        Slider(value: $settings.fontSize, in: 22...64, step: 1)
                    }
                }

                HStack(spacing: 8) {
                    pill("Mirror", on: settings.mirror) { settings.mirror.toggle() }
                    pill("Guide", on: settings.showGuide) { settings.showGuide.toggle() }
                    pill("Restart", on: false) { restart() }
                }
            }
            .tint(settings.accent)
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .padding(.bottom, 14)
            .background(
                LinearGradient(colors: [.black.opacity(0), .black.opacity(0.92)], startPoint: .top, endPoint: .center)
                    .ignoresSafeArea()
            )
        }
    }

    private func labelRow(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name).tracking(1)
            Spacer()
            Text(value).foregroundColor(Theme.fg).fontWeight(.semibold)
        }
        .font(.system(size: 10.5))
        .foregroundColor(Theme.muted)
    }

    private func pill(_ title: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12.5, weight: on ? .semibold : .regular))
                .foregroundColor(on ? .black : Theme.muted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(on ? Theme.fg : Theme.surface2, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: Actions

    private func togglePlay() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if engine.running {
            engine.pause()
            return
        }
        if countdown != nil {
            countdownTask?.cancel()
            countdown = nil
            return
        }
        if settings.countdown > 0 && engine.offset == 0 {
            countdownTask = Task { @MainActor in
                for n in stride(from: settings.countdown, to: 0, by: -1) {
                    countdown = n
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    if Task.isCancelled { countdown = nil; return }
                }
                countdown = nil
                engine.start()
            }
        } else {
            engine.start()
        }
    }

    private func restart() {
        countdownTask?.cancel()
        countdown = nil
        engine.restart()
    }
}
