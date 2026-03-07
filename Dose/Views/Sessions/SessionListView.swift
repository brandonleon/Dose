import SwiftUI
import SwiftData

struct SessionListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var proManager: ProManager
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]
    @State private var searchText = ""
    @State private var showUpgrade = false

    private var visibleSessions: [Session] {
        let dateFiltered = proManager.isPro
            ? sessions
            : sessions.filter { $0.timestamp >= ProManager.freeHistoryStart }
        if searchText.isEmpty { return dateFiltered }
        return dateFiltered.filter { session in
            session.dosageMethod.displayName.localizedCaseInsensitiveContains(searchText)
            || (session.strain?.name.localizedCaseInsensitiveContains(searchText) ?? false)
            || session.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var hiddenCount: Int {
        guard !proManager.isPro else { return 0 }
        return sessions.filter { $0.timestamp < ProManager.freeHistoryStart }.count
    }

    private var groupedByDate: [(date: Date, sessions: [Session])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: visibleSessions) { session in
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

            if hiddenCount > 0 {
                Section {
                    Button {
                        showUpgrade = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(hiddenCount) older session\(hiddenCount == 1 ? "" : "s") hidden")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                Text("Upgrade to Pro to view your full history")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
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
        .sheet(isPresented: $showUpgrade) {
            ProUpgradeView()
        }
    }
}
