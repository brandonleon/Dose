import SwiftUI
import SwiftData

struct SessionListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]
    @State private var searchText = ""

    private var filteredSessions: [Session] {
        if searchText.isEmpty { return sessions }
        return sessions.filter { session in
            session.dosageMethod.displayName.localizedCaseInsensitiveContains(searchText)
            || (session.strain?.name.localizedCaseInsensitiveContains(searchText) ?? false)
            || session.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedByDate: [(date: Date, sessions: [Session])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredSessions) { session in
            calendar.startOfDay(for: session.timestamp)
        }
        return grouped.map { (date: $0.key, sessions: $0.value) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            ForEach(groupedByDate, id: \.date) { group in
                Section(DateFormatters.monthDay.string(from: group.date)) {
                    ForEach(group.sessions) { session in
                        NavigationLink(value: session) {
                            SessionRowView(session: session)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            modelContext.delete(group.sessions[index])
                        }
                    }
                }
            }
        }
        .overlay {
            if sessions.isEmpty {
                EmptyStateView(
                    icon: "leaf.circle",
                    title: "No Sessions",
                    message: "Log your first session from the Dashboard."
                )
            }
        }
        .searchable(text: $searchText, prompt: "Search sessions")
        .navigationTitle("All Sessions")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Session.self) { session in
            SessionDetailView(session: session)
        }
    }
}
