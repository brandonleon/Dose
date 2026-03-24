import SwiftUI
import SwiftData
import WidgetKit

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var showQuickLog: Bool
    @Query(filter: #Predicate<Session> { _ in true },
           sort: \Session.timestamp, order: .reverse)
    private var allSessions: [Session]
    @State private var sessionToEdit: Session?
    @State private var sessionToDelete: Session?

    private var todaySessions: [Session] {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        return allSessions.filter { $0.timestamp >= startOfDay }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                TodaySummaryView(sessions: todaySessions)

                // Quick log buttons
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Log")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                        ForEach(DosageMethod.allCases) { method in
                            Button {
                                quickLog(method: method)
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: method.iconName)
                                        .font(.title2)
                                    Text(method.displayName)
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(themeManager.cardBackground, in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Detailed log button
                Button {
                    showQuickLog = true
                } label: {
                    Label("Detailed Log", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.accentColor, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }

                // Today's sessions
                if !todaySessions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Sessions")
                            .font(.headline)

                        ForEach(Array(todaySessions.enumerated()), id: \.element.id) { index, session in
                            SessionCardView(
                                session: session,
                                showTimeSince: index == 0
                            )
                            .contextMenu {
                                Button {
                                    sessionToEdit = session
                                } label: {
                                    Label("Edit Session", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    sessionToDelete = session
                                } label: {
                                    Label("Delete Session", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Kanalog")
        .sheet(isPresented: $showQuickLog) {
            QuickLogSheet()
        }
        .sheet(item: $sessionToEdit) { session in
            EditSessionSheet(session: session)
        }
        .alert("Delete Session?", isPresented: Binding(
            get: { sessionToDelete != nil },
            set: { if !$0 { sessionToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let session = sessionToDelete {
                    modelContext.delete(session)
                    try? modelContext.save()
                    WidgetCenter.shared.reloadAllTimelines()
                }
                sessionToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                sessionToDelete = nil
            }
        } message: {
            Text("This cannot be undone.")
        }
    }

    private func quickLog(method: DosageMethod) {
        let session = Session(dosageMethod: method)
        modelContext.insert(session)
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
