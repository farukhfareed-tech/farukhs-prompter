import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var store: ScriptStore
    @EnvironmentObject var settings: AppSettings
    @State private var path = NavigationPath()
    @State private var query = ""

    private var visible: [Script] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        if q.isEmpty { return store.scripts }
        return store.scripts.filter { $0.title.lowercased().contains(q) || $0.body.lowercased().contains(q) }
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header
                searchField
                List {
                    ForEach(visible) { s in
                        NavigationLink(value: s.id) { row(s) }
                            .listRowBackground(Color.clear)
                            .listRowSeparatorTint(Theme.line)
                    }
                    .onDelete { store.delete(at: $0, in: visible) }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Theme.bg.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: UUID.self) { id in
                EditorView(id: id)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                Text("FARUKH'S PROMPTER")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2.4)
                    .foregroundColor(settings.accent)
                Text("Scripts")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(Theme.fg)
            }
            Spacer()
            Button {
                let id = store.add()
                path.append(id)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 42, height: 42)
                    .background(settings.accent, in: Circle())
            }
            .accessibilityLabel("New script")
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(Theme.muted)
            TextField("Search scripts", text: $query)
                .foregroundColor(Theme.fg)
                .autocorrectionDisabled()
        }
        .padding(12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line))
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
    }

    private func row(_ s: Script) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(s.title.isEmpty ? "Untitled script" : s.title)
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(Theme.fg)
            if !s.preview.isEmpty {
                Text(s.preview)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.muted)
                    .lineLimit(2)
            }
            HStack(spacing: 14) {
                Text(s.readTime).foregroundColor(settings.accent).fontWeight(.semibold)
                Text("\(s.wordCount) words")
                Text(s.tag)
            }
            .font(.system(size: 11.5))
            .foregroundColor(Theme.muted)
        }
        .padding(.vertical, 8)
    }
}
