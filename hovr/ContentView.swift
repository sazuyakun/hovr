import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var cursorManager: CursorManager

    private let columns = Array(repeating: GridItem(.flexible(minimum: 88, maximum: 96), spacing: 12), count: 5)

    var body: some View {
        VStack(spacing: 28) {
            Text("Hovr")
                .font(.system(size: 24, weight: .semibold))

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(CursorOption.allCases) { option in
                    CursorCard(option: option, isSelected: cursorManager.selectedOption == option) {
                        cursorManager.apply(option)
                    }
                }
            }

            VStack(spacing: 8) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 44, height: 44)

                Text("hovr v1.0.0")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(width: 560, height: 300)
    }
}

private struct CursorCard: View {
    let option: CursorOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action, label: {
            VStack(spacing: 10) {
                CursorPreview(option: option, size: 18)

                Text(option.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.accentColor : Color.black.opacity(0.08), lineWidth: isSelected ? 2 : 1)
            )
        })
        .buttonStyle(.plain)
    }
}

struct CursorPreview: View {
    let option: CursorOption
    let size: CGFloat

    var body: some View {
        Text(option.emoji)
            .font(.system(size: size))
            .frame(width: size, height: size)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CursorManager())
    }
}
