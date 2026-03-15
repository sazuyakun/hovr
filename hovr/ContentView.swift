import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var cursorManager: CursorManager

    private let columns = Array(repeating: GridItem(.flexible(minimum: 88, maximum: 96), spacing: 12), count: 5)

    var body: some View {
        VStack(spacing: 28) {
            HStack(spacing: 8) {
                Text("Hovr")
                    .font(.system(size: 24, weight: .semibold))

                ResetButton(isActive: cursorManager.selectedOption != nil) {
                    cursorManager.restoreSystemCursor()
                }
            }

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
            SurfaceCard(
                cornerRadius: 12,
                lineWidth: isSelected ? 2 : 1,
                strokeColor: isSelected ? Color.accentColor : Color.black.opacity(0.08)
            ) {
                VStack(spacing: 10) {
                    CursorPreview(option: option, size: 18)

                    Text(option.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 92)
            }
        })
        .buttonStyle(.plain)
    }
}

private struct SurfaceCard<Content: View>: View {
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let strokeColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor, lineWidth: lineWidth)
            )
    }
}

private struct ResetButton: View {
    let isActive: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action, label: {
            SurfaceCard(
                cornerRadius: 10,
                lineWidth: 1,
                strokeColor: isHovered && isActive ? Color.black.opacity(0.14) : Color.black.opacity(0.08)
            ) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(
                        isActive
                            ? (isHovered ? Color.primary : Color.secondary)
                            : Color.secondary.opacity(0.3)
                    )
                    .frame(width: 32, height: 32)
                    .animation(.easeInOut(duration: 0.15), value: isHovered)
            }
        })
        .buttonStyle(.plain)
        .disabled(!isActive)
        .onHover { isHovered = $0 }
        .help("Reset to default cursor")
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
