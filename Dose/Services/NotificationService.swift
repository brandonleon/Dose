import UserNotifications

final class NotificationService: Sendable {
    static let shared = NotificationService()

    func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])) ?? false
    }

    func scheduleTBreakReminder(dayNumber: Int, from startDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "T-Break Day \(dayNumber)"
        content.body = dayNumber == 1
            ? "Your tolerance break has started. You've got this!"
            : "Day \(dayNumber) of your tolerance break. Stay strong!"
        content.sound = .default

        guard let fireDate = Calendar.current.date(byAdding: .day, value: dayNumber - 1, to: startDate) else { return }
        var components = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
        components.hour = 9

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "tbreak-day-\(dayNumber)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleReminders(for goalDays: Int, from startDate: Date) {
        for day in 1...min(goalDays, 90) {
            scheduleTBreakReminder(dayNumber: day, from: startDate)
        }
    }

    func cancelAllTBreakReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: (1...90).map { "tbreak-day-\($0)" }
        )
    }
}
