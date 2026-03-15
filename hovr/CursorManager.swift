import AppKit
import Combine
import SwiftUI

enum CursorOption: String, CaseIterable, Identifiable {
    case spark = "Spark"
    case sun = "Sun"
    case leaf = "Leaf"
    case flame = "Flame"
    case moon = "Moon"

    var id: String { rawValue }

    var name: String { rawValue }

    var emoji: String {
        switch self {
        case .spark:
            return "✨"
        case .sun:
            return "☀️"
        case .leaf:
            return "🍃"
        case .flame:
            return "🔥"
        case .moon:
            return "🌙"
        }
    }
}

@MainActor
final class CursorManager: ObservableObject {
    @Published private(set) var selectedOption: CursorOption?

    private let overlayController = CursorOverlayController()

    func apply(_ option: CursorOption) {
        selectedOption = option
        overlayController.showCursor(option)
    }

    func restoreSystemCursor() {
        overlayController.restoreSystemCursor()
    }
}

@MainActor
private final class CursorOverlayController {
    private var windows: [CursorOverlayWindow] = []
    private var timer: Timer?
    private var isCursorHidden = false
    private var currentOption: CursorOption?

    func showCursor(_ option: CursorOption) {
        currentOption = option

        if windows.isEmpty {
            windows = NSScreen.screens.map(CursorOverlayWindow.init(screen:))
        }

        windows.forEach { $0.update(option: option) }

        if !isCursorHidden {
            CGDisplayHideCursor(kCGNullDirectDisplay)
            isCursorHidden = true
        }

        windows.forEach { $0.orderFrontRegardless() }
        updateCursorPosition()
        startTimer()
    }

    func restoreSystemCursor() {
        timer?.invalidate()
        timer = nil
        windows.forEach { $0.orderOut(nil) }

        if isCursorHidden {
            CGDisplayShowCursor(kCGNullDirectDisplay)
            isCursorHidden = false
        }
    }

    private func startTimer() {
        guard timer == nil else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateCursorPosition()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func updateCursorPosition() {
        guard currentOption != nil else { return }

        let location = NSEvent.mouseLocation

        for window in windows {
            if window.screenFrame.contains(location) {
                window.updatePosition(location)
                window.orderFrontRegardless()
            } else {
                window.hideCursor()
            }
        }
    }
}

private final class CursorOverlayWindow: NSWindow {
    let screenFrame: CGRect

    private let label = NSTextField(labelWithString: "")
    private let cursorSize: CGFloat = 18
    private let hotSpot = CGPoint(x: 3, y: 15)

    init(screen: NSScreen) {
        screenFrame = screen.frame

        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false,
            screen: screen
        )

        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = true
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]

        label.alignment = .center
        label.backgroundColor = .clear
        label.textColor = .labelColor
        label.font = .systemFont(ofSize: cursorSize)
        label.frame = CGRect(origin: .zero, size: CGSize(width: cursorSize, height: cursorSize))
        label.isHidden = true

        contentView = NSView(frame: CGRect(origin: .zero, size: screen.frame.size))
        contentView?.wantsLayer = true
        contentView?.layer?.backgroundColor = NSColor.clear.cgColor
        contentView?.addSubview(label)
    }

    override var canBecomeKey: Bool { false }

    func update(option: CursorOption) {
        label.stringValue = option.emoji
        label.isHidden = false
    }

    func updatePosition(_ globalLocation: CGPoint) {
        let localX = globalLocation.x - screenFrame.minX - hotSpot.x
        let localY = globalLocation.y - screenFrame.minY - (cursorSize - hotSpot.y)
        label.frame.origin = CGPoint(x: localX, y: localY)
        label.isHidden = false
    }

    func hideCursor() {
        label.isHidden = true
    }
}
