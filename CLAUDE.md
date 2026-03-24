# Kanalog — Claude Code Instructions

## Project Overview

**Kanalog** is an iOS app for tracking cannabis consumption and its effect on back pain. Built with SwiftUI + SwiftData targeting iOS 17+, with a WidgetKit extension for home screen glanceability.

- **Bundle ID**: `com.brandonleon.Dose`
- **Widget Bundle ID**: `com.brandonleon.Dose.DoseWidget`
- **App Group**: `group.com.brandonleon.Dose` (shared between app and widget)
- **URL Scheme**: `kanalog://` (e.g., `kanalog://quicklog` opens QuickLogSheet)
- **Swift Version**: 6.0 (strict concurrency enabled)
- **Deployment Target**: iOS 17.0
- **Project Generator**: XcodeGen — edit `project.yml`, not `.pbxproj` directly

---

## Build Environment

```bash
# Always use Xcode.app toolchain for CLI builds (not CommandLineTools)
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun xcodebuild ...

# Build for simulator without code signing (CI-safe)
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun xcodebuild \
  -scheme Kanalog -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build
```

- Xcode is at `/Applications/Xcode.app`
- iOS SDK: `iPhoneOS26.2.sdk`
- Active developer dir defaults to CommandLineTools — always set `DEVELOPER_DIR` explicitly for `xcrun` calls

---

## Architecture

### Pattern
SwiftUI + SwiftData, MVVM-lite. Views own their `@Query` and `@State` directly — there are no separate ViewModel classes. The `ViewModels/` directory exists but is intentionally empty.

### Navigation
5-tab `TabView` in `ContentView.swift`, each tab in its own `NavigationStack`:

| Tab | Icon | Root View |
|-----|------|-----------|
| Dashboard | `house.fill` | `DashboardView` |
| Pain Journal | `book.fill` | `PainJournalView` |
| T-Break | `timer` | `TBreakView` |
| Stats | `chart.bar.fill` | `StatsView` |
| Settings | `gearshape.fill` | `SettingsView` |

### Data Flow
- **SwiftData**: All persistence. `@Query` at the view layer, `modelContext.insert/delete` for mutations.
- **ThemeManager**: `ObservableObject` singleton, injected as `.environmentObject()` in `DoseApp`. Persists to shared `UserDefaults` so the widget can read the accent color.
- **App Group**: `SharedContainer` enum provides the shared `UserDefaults` suite and the `ModelContainer` file URL used by both app and widget.

---

## File Structure

```
Dose/
├── DoseApp.swift                  # @main, ThemeManager init, deep link handler
├── ContentView.swift              # 5-tab TabView root
│
├── Models/
│   ├── Session.swift              # Core consumption record
│   ├── Strain.swift               # Cannabis strain info
│   ├── PainEntry.swift            # Standalone pain log entry
│   ├── TBreak.swift               # Tolerance break record
│   ├── DosageMethod.swift         # Enum: 8 consumption methods
│   └── StrainType.swift           # Enum: indica / sativa / hybrid
│
├── Theme/
│   ├── AccentColor.swift          # Enum: 13 predefined colors + custom
│   ├── ThemeManager.swift         # ObservableObject, persists to App Group UserDefaults
│   └── Color+Extensions.swift     # Hex parsing/serialization helpers
│
├── Services/
│   ├── SharedContainer.swift      # App Group identifier + shared defaults/URL
│   ├── PersistenceConfiguration.swift  # ModelContainer setup (schema + URL)
│   ├── ExportService.swift        # CSV export for sessions & pain entries
│   └── NotificationService.swift  # T-Break daily reminders (UNUserNotificationCenter)
│
├── Utilities/
│   └── DateFormatters.swift       # Static DateFormatter instances
│
└── Views/
    ├── Dashboard/
    │   ├── DashboardView.swift
    │   ├── TodaySummaryView.swift
    │   ├── SessionCardView.swift
    │   ├── QuickLogSheet.swift     # Primary session entry form
    │   └── EditSessionSheet.swift  # Edit existing session (adds DatePicker)
    ├── PainJournal/
    │   ├── PainJournalView.swift
    │   └── PainEntryFormView.swift
    ├── TBreak/
    │   ├── TBreakView.swift
    │   ├── TBreakStreakView.swift
    │   └── TBreakTimelineView.swift  # Swift Charts bar chart (last 30 days)
    ├── Stats/
    │   ├── StatsView.swift         # DateRange picker + child charts
    │   ├── ConsumptionTrendChart.swift
    │   ├── MethodEffectivenessChart.swift
    │   ├── StrainEffectivenessChart.swift
    │   └── DailySummaryView.swift
    ├── Settings/
    │   ├── SettingsView.swift
    │   ├── ThemePickerView.swift
    │   ├── ExportView.swift
    │   └── AboutView.swift
    ├── Strains/
    │   ├── StrainLibraryView.swift
    │   ├── StrainDetailView.swift
    │   ├── StrainFormView.swift
    │   └── StrainPickerView.swift   # Used inside QuickLogSheet
    ├── Sessions/
    │   ├── SessionListView.swift    # Full searchable history, grouped by date
    │   ├── SessionDetailView.swift
    │   └── SessionRowView.swift
    └── Components/
        ├── StatCard.swift
        ├── PainScaleSlider.swift    # Slider 1–10 with pain-level color coding
        ├── PainScaleView.swift      # 10-bar read-only pain level indicator
        ├── DosageMethodPicker.swift # Grid picker for all 8 methods
        ├── EmptyStateView.swift     # Wrapper around ContentUnavailableView
        └── AccentButton.swift       # Full-width primary action button

DoseWidget/
├── DoseWidgetBundle.swift
└── DoseWidget.swift                # TimelineProvider + EntryView + Entry model

DoseTests/                          # Empty — no tests yet
project.yml                         # XcodeGen source-of-truth for project config
```

---

## SwiftData Models

### Session
| Property | Type | Notes |
|----------|------|-------|
| `timestamp` | `Date` | When the session occurred |
| `dosageMethodRaw` | `String` | Backing store for `dosageMethod` enum |
| `dosageAmount` | `String?` | Free-text amount (e.g., "0.5g") |
| `painLevelBefore` | `Int?` | 1–10 |
| `painLevelAfter` | `Int?` | 1–10 |
| `notes` | `String` | |
| `strain` | `Strain?` | Optional relationship |
| `dosageMethod` | computed | `DosageMethod` via raw value |
| `painDelta` | computed | `after - before`, nil if either missing |

### Strain
| Property | Type | Notes |
|----------|------|-------|
| `name` | `String` | |
| `strainTypeRaw` | `String` | Backing store for `strainType` enum |
| `thcPercentage` | `Double?` | |
| `cbdPercentage` | `Double?` | |
| `notes` | `String` | |
| `isFavorite` | `Bool` | |
| `createdAt` | `Date` | |
| `sessions` | `[Session]` | Delete rule: `.nullify` |
| `strainType` | computed | `StrainType` via raw value |

### PainEntry
| Property | Type | Notes |
|----------|------|-------|
| `timestamp` | `Date` | |
| `painLevel` | `Int` | 1–10 |
| `location` | `String` | Defaults to "Lower back" |
| `notes` | `String` | |
| `activityContext` | `String?` | e.g., "After sitting" |

### TBreak
| Property | Type | Notes |
|----------|------|-------|
| `startDate` | `Date` | |
| `targetEndDate` | `Date?` | Derived from `goalDays` |
| `actualEndDate` | `Date?` | Nil = break is active |
| `goalDays` | `Int?` | |
| `notes` | `String` | |
| `isActive` | computed | `actualEndDate == nil` |
| `currentStreakDays` | computed | Days elapsed |
| `progress` | computed | 0.0–1.0 toward goal |

### Enum Storage Pattern
Enums are **not** stored directly in SwiftData — store the raw `String` and expose via a computed property:

```swift
// In the @Model class:
var dosageMethodRaw: String = DosageMethod.flower.rawValue

var dosageMethod: DosageMethod {
    get { DosageMethod(rawValue: dosageMethodRaw) ?? .other }
    set { dosageMethodRaw = newValue.rawValue }
}
```

---

## Theming

- **ThemeManager** is the single source of truth for accent color.
- Always access it via `@EnvironmentObject var themeManager: ThemeManager`.
- Use `.tint(themeManager.accentColor)` on container views — NOT `.accentColor()` (deprecated).
- `Color.accentColor` is valid as a `ShapeStyle`; `.accent` is not.
- The widget reads `accentColorHex` from the shared `UserDefaults` suite; ThemeManager writes it there on change.

```swift
// Correct
.tint(themeManager.accentColor)

// Wrong
.accentColor(themeManager.accentColor)  // deprecated
.foregroundStyle(.accent)               // .accent is not a valid ShapeStyle
```

---

## Swift 6 Gotchas

### String Formatting
`specifier:` in string interpolation was removed in Swift 6.2. Use `String(format:)`:

```swift
// Wrong (Swift 6.2+)
Text("\(value, specifier: "%.1f")")

// Correct
Text(String(format: "%.1f", value))
```

### Widget Concurrency
`TimelineProvider` methods must be `nonisolated` and dispatch to `@MainActor` for SwiftData access:

```swift
nonisolated func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    Task { @MainActor in
        // SwiftData queries here
        completion(timeline)
    }
}
```

---

## Key Conventions

### Pain Level Colors
Consistent throughout the app — do not change thresholds:

```swift
func painColor(_ level: Int) -> Color {
    switch level {
    case 1...3: return .green
    case 4...6: return .yellow
    case 7...8: return .orange
    default:    return .red
    }
}
```

### Date Helpers
Use `DateFormatters` static instances — never create inline formatters:

```swift
DateFormatters.timeOnly.string(from: date)
DateFormatters.shortDate.string(from: date)
DateFormatters.mediumDateTime.string(from: date)
DateFormatters.dayOfWeek.string(from: date)   // "Monday"
DateFormatters.monthDay.string(from: date)    // "Feb 20"
```

### Empty States
Every list or query result view must include `EmptyStateView` when the collection is empty:

```swift
EmptyStateView(icon: "...", title: "...", message: "...")
```

### Data Deletion
Always confirm destructive deletes via `.alert` or `.confirmationDialog` before calling `modelContext.delete()`.

### Deep Links
`DoseApp.onOpenURL` handles `kanalog://quicklog`. If adding new deep link paths, handle them in the same `onOpenURL` modifier and document the scheme here.

---

## Widget

The widget (`DoseWidget`) is a `StaticConfiguration` supporting `.systemSmall` and `.systemMedium`. It:

1. Reads today's sessions from the **shared** `ModelContainer` (via `SharedContainer.containerURL`)
2. Reads the accent color hex from shared `UserDefaults`
3. Provides a deep link button (`kanalog://quicklog`) in the medium variant
4. Refreshes every 30 minutes

When modifying models that the widget reads (Session, ThemeManager), ensure the widget's data access path still works via `SharedContainer`.

---

## Notifications

`NotificationService` handles T-Break reminders:

- Requests authorization on first T-Break start
- Schedules daily 9 AM reminders for up to 90 days
- All reminders use identifiers prefixed with `"tbreak-"` — cancel with `cancelAllTBreakReminders()`
- The service is `Sendable`; call from any context

---

## Adding Features — Checklist

When adding a new tab, model, or major feature:

- [ ] Add `@Model` class to `Dose/Models/` and register it in `PersistenceConfiguration.schema`
- [ ] If the widget needs the model, add it to the widget's file references in `project.yml`
- [ ] Add any new enum with a raw `String` type and follow the computed-property pattern
- [ ] New views go under `Views/<FeatureName>/`
- [ ] Reusable components go under `Views/Components/`
- [ ] Provide an `EmptyStateView` for any list
- [ ] Use `.tint(themeManager.accentColor)` for themed interactive elements
- [ ] Use `DateFormatters` for any date display
- [ ] Run `xcodegen generate` after editing `project.yml`

---

## No CloudKit

Persistence is **local-only**. `PersistenceConfiguration` explicitly disables CloudKit. Do not add `.cloudKitDatabase()` or iCloud sync unless the user explicitly requests it.
