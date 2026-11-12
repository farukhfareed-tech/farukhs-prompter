import SwiftUI

struct EditorView: View {
    let id: UUID
    @EnvironmentObject var store: ScriptStore
    @EnvironmentObject var settings: AppSettings
    @State private var showPrompter = false

    var body: some View {
        if let idx = store.scripts.firstIndex(where: { $0.id == id }) {
            content(idx)
        } else {
            Color.black.ignoresSafeArea()
        }
    }

    private func content(_ idx: Int) -> some View {
        VStack(spacing: 0) {
            TextField("Title", text: $store.scripts[idx].title)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(Theme.fg)
                .padding(.horizontal, 24)
                .padding(.top, 8)

            TextEditor(text: $store.scripts[idx].body)
                .scrollContentBackground(.hidden)
                .font(.system(size: 17))
                .foregroundColor(Theme.fg.opacity(0.9))
                .lineSpacing(5)
                .padding(.horizontal, 19)
                .padding(.top, 6)

            Divider().overlay(Theme.line)

            HStack(spacing: 8) {
                ForEach(["[pause]", "[smile]", "[slow]"], id: \.self) { cue in
                    Button {
                        store.scripts[idx].body += (store.scripts[idx].body.hasSuffix(" ") || store.scripts[idx].body.isEmpty ? "" : " ") + cue + " "
                    } label: {
                        Text("+ \(cue)")
                            .font(.system(size: 12.5))
                            .foregroundColor(settings.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Theme.surface2, in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                Spacer()
                Text("\(store.scripts[idx].wordCount) words · \(store.scripts[idx].readTime)")
                    .font(.system(size: 11.5))
                    .foregroundColor(Theme.muted)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)

            Button {
                hideKeyboard()
                showPrompter = true
            } label: {
                Text("Start prompter")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(settings.accent, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            .disabled(store.scripts[idx].body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { store.scripts[idx].updated = Date() }
        .fullScreenCover(isPresented: $showPrompter) {
            PrompterView(script: store.scripts[idx])
                .environmentObject(settings)
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
