import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    sample
                        .listRowBackground(Theme.surface)
                }

                Section("Reading") {
                    HStack {
                        Text("Text size")
                        Slider(value: $settings.fontSize, in: 22...64, step: 1)
                        Text("\(Int(settings.fontSize))").foregroundColor(Theme.muted).frame(width: 32)
                    }
                    .listRowBackground(Theme.surface)

                    HStack {
                        Text("Scroll speed")
                        Slider(value: $settings.speed, in: 10...120, step: 1)
                        Text("\(Int(settings.speed))").foregroundColor(Theme.muted).frame(width: 32)
                    }
                    .listRowBackground(Theme.surface)

                    HStack {
                        Text("Accent colour")
                        Spacer()
                        ForEach(AccentChoice.allCases) { c in
                            Button { settings.accentChoice = c } label: {
                                Circle().fill(c.color)
                                    .frame(width: 26, height: 26)
                                    .overlay(Circle().stroke(Color.white, lineWidth: settings.accentChoice == c ? 2 : 0))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(c.rawValue.capitalized)
                        }
                    }
                    .listRowBackground(Theme.surface)

                    Toggle("Reading guide", isOn: $settings.showGuide)
                        .listRowBackground(Theme.surface)
                    Toggle("Mirror text", isOn: $settings.mirror)
                        .listRowBackground(Theme.surface)
                }

                Section("Start") {
                    Picker("Countdown", selection: $settings.countdown) {
                        Text("Off").tag(0)
                        Text("3 seconds").tag(3)
                        Text("5 seconds").tag(5)
                    }
                    .listRowBackground(Theme.surface)
                }

                Section {
                    VStack(spacing: 4) {
                        Text("Farukh's Prompter")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.fg)
                        Text("Designed and owned by Farukh")
                        Text("Version 1.0 · Private, no account")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(Theme.muted)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("Settings")
        }
    }

    private var sample: some View {
        Text("The words you read\nwill look like this.")
            .font(.system(size: settings.fontSize * 0.78, weight: .semibold))
            .multilineTextAlignment(.center)
            .foregroundColor(Theme.fg)
            .scaleEffect(x: settings.mirror ? -1 : 1, y: 1)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
    }
}
