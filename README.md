# Dose

A personal iOS app for tracking cannabis consumption and its effect on back pain. Log sessions, monitor pain levels, manage strains, take tolerance breaks, and view trends — all stored locally on device.

## Features

- **Dashboard** — Quick-log any of 8 consumption methods in one tap; view today's sessions at a glance
- **Session Logging** — Record method, strain, amount, pain level before/after, and free-text notes
- **Pain Journal** — Standalone pain entries with location, activity context, and a 1–10 scale
- **Strain Library** — Save strains with type (indica/sativa/hybrid), THC/CBD percentages, and favorites
- **Tolerance Break Tracker** — Start a T-Break with a goal, track streaks, get daily reminders
- **Stats** — Charts for consumption trends, method effectiveness, and strain effectiveness over custom date ranges
- **CSV Export** — Export sessions and pain entries for use in other tools
- **Home Screen Widget** — Small and medium widgets showing today's session count with a quick-log deep link
- **Theming** — 13 accent color presets (+ custom hex), dark mode by default

## Requirements

| Requirement | Version |
|-------------|---------|
| iOS | 17.0+ |
| Xcode | 16.2+ |
| Swift | 6.0 |
| XcodeGen | Any recent version |

## Getting Started

### 1. Install XcodeGen

```bash
brew install xcodegen
```

### 2. Generate the Xcode project

```bash
cd Dose
xcodegen generate
```

### 3. Open and run

```bash
open Dose.xcodeproj
```

Select a simulator or device and press **Run** (⌘R).

> **Note:** The project uses an App Group (`group.com.brandonleon.Dose`) shared between the app and widget extension. You will need to configure your own development team and provisioning profiles in Xcode before running on a physical device.

### CLI Build (no code signing)

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun xcodebuild \
  -scheme Dose -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build
```

## Architecture

- **SwiftUI + SwiftData** — No UIKit; `@Query` at the view layer for persistence
- **MVVM-lite** — Views own their state and queries directly; no separate ViewModel classes
- **ThemeManager** — `ObservableObject` singleton injected via `.environmentObject()`; writes accent color to the shared `UserDefaults` suite so the widget can read it
- **App Group** — `SharedContainer` provides the shared `UserDefaults` suite and `ModelContainer` file URL used by both targets
- **Local-only** — No CloudKit or iCloud sync; all data lives on device

## Project Structure

```
Dose/
├── Models/          # SwiftData @Model classes (Session, Strain, PainEntry, TBreak)
├── Theme/           # ThemeManager, AccentColor enum, Color helpers
├── Services/        # SharedContainer, PersistenceConfiguration, ExportService, NotificationService
├── Utilities/       # DateFormatters
└── Views/
    ├── Dashboard/   # DashboardView, QuickLogSheet, SessionCardView
    ├── PainJournal/ # PainJournalView, PainEntryFormView
    ├── TBreak/      # TBreakView, streaks, timeline chart
    ├── Stats/       # StatsView, consumption/method/strain charts
    ├── Settings/    # SettingsView, ThemePickerView, ExportView
    ├── Strains/     # StrainLibraryView, StrainDetailView, StrainFormView, StrainPickerView
    ├── Sessions/    # SessionListView, SessionDetailView, SessionRowView
    └── Components/  # Reusable UI (PainScaleSlider, DosageMethodPicker, StatCard, etc.)

DoseWidget/          # WidgetKit extension (small + medium)
project.yml          # XcodeGen source-of-truth — edit this, not .pbxproj
```

## Consumption Methods

Flower · Vape · Edible · Tincture · Topical · Concentrate · Capsule · Other

## Deep Links

| URL | Action |
|-----|--------|
| `dose://quicklog` | Opens the detailed session log sheet |

The widget's medium variant uses this URL so tapping it opens the app directly to the log form.

## Notifications

Tolerance break reminders are scheduled as daily 9 AM local notifications for up to 90 days. Notification permission is requested the first time a T-Break is started. All reminders use the `"tbreak-"` identifier prefix and can be cancelled when a break ends.

## Data Export

Go to **Settings → Export** to export your sessions or pain entries as CSV files, shareable via the system share sheet.

## Privacy

All data is stored locally using SwiftData. Nothing is sent to external servers. There is no analytics, telemetry, or account system.
