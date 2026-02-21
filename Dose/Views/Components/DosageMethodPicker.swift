import SwiftUI

struct DosageMethodPicker: View {
    @Binding var selection: DosageMethod
    @EnvironmentObject private var themeManager: ThemeManager

    let columns = [GridItem(.adaptive(minimum: 72))]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(DosageMethod.allCases) { method in
                Button {
                    selection = method
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: method.iconName)
                            .font(.title3)
                        Text(method.displayName)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selection == method
                            ? themeManager.accentColor.opacity(0.2)
                            : Color(.systemGray5),
                        in: RoundedRectangle(cornerRadius: 10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selection == method ? themeManager.accentColor : .clear, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
