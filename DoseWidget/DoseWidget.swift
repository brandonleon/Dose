import WidgetKit
import SwiftUI
import SwiftData

struct DoseEntry: TimelineEntry {
    let date: Date
    let sessionCountToday: Int
    let lastMethodRaw: String?
    let lastStrainName: String?
    let accentColorHex: String

    var lastMethod: DosageMethod? {
        guard let raw = lastMethodRaw else { return nil }
        return DosageMethod(rawValue: raw)
    }
}

struct DoseTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> DoseEntry {
        DoseEntry(date: .now, sessionCountToday: 3, lastMethodRaw: "flower", lastStrainName: nil, accentColorHex: "#33C778")
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (DoseEntry) -> Void) {
        let entry = makeEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<DoseEntry>) -> Void) {
        let entry = makeEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func makeEntry() -> DoseEntry {
        let defaults = UserDefaults(suiteName: SharedContainer.appGroupIdentifier)
        let accentRaw = defaults?.string(forKey: "dose_accent_color") ?? "emerald"
        let customHex = defaults?.string(forKey: "dose_custom_hex") ?? "#33C778"

        let resolvedHex: String
        if accentRaw == "custom" {
            resolvedHex = customHex
        } else {
            resolvedHex = (AccentColor(rawValue: accentRaw) ?? .emerald).color.hexString
        }

        // Use a background model context for widget data fetching
        do {
            let container = PersistenceConfiguration.sharedModelContainer
            let context = ModelContext(container)
            let startOfDay = Calendar.current.startOfDay(for: .now)

            let descriptor = FetchDescriptor<Session>(
                predicate: #Predicate<Session> { $0.timestamp >= startOfDay },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )

            let sessions = try context.fetch(descriptor)
            return DoseEntry(
                date: .now,
                sessionCountToday: sessions.count,
                lastMethodRaw: sessions.first?.dosageMethodRaw,
                lastStrainName: sessions.first?.strain?.name,
                accentColorHex: resolvedHex
            )
        } catch {
            return DoseEntry(
                date: .now,
                sessionCountToday: 0,
                lastMethodRaw: nil,
                lastStrainName: nil,
                accentColorHex: resolvedHex
            )
        }
    }
}

struct DoseWidgetEntryView: View {
    var entry: DoseEntry
    @Environment(\.widgetFamily) var family

    private var accent: Color {
        Color(hex: entry.accentColorHex) ?? .green
    }

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(accent)
                Text("Dose")
                    .font(.headline)
            }

            Text("\(entry.sessionCountToday)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(accent)

            Text("sessions today")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    private var mediumView: some View {
        HStack {
            smallView

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                if let method = entry.lastMethod {
                    Label(method.displayName, systemImage: method.iconName)
                        .font(.subheadline)
                }
                if let strain = entry.lastStrainName {
                    Label(strain, systemImage: "leaf")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Link(destination: URL(string: "dose://quicklog")!) {
                    Label("Quick Log", systemImage: "plus.circle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(accent)
                }
            }
            .padding(.leading, 8)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct DoseWidget: Widget {
    let kind: String = "DoseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DoseTimelineProvider()) { entry in
            DoseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Dose Today")
        .description("Today's session count with quick-log access.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
