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
        case .spark: return "✨"
        case .sun: return "☀️"
        case .leaf: return "🍃"
        case .flame: return "🔥"
        case .moon: return "🌙"
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
        selectedOption = nil
        overlayController.restoreSystemCursor()
    }
}

@MainActor
private final class CursorOverlayController {
    private let window = CursorOverlayWindow()
    private var timer: Timer?
    private var hideCount = 0

    func showCursor(_ option: CursorOption) {
        window.update(option: option)
        window.orderFrontRegardless()
        updateCursorPosition()

        if hideCount == 0 {
            NSCursor.hide()
            CGDisplayHideCursor(CGMainDisplayID())
        }
        hideCount = 1

        startTimer()
    }

    func restoreSystemCursor() {
        timer?.invalidate()
        timer = nil
        window.orderOut(nil)

        guard hideCount > 0 else { return }

        NSCursor.unhide()
        CGDisplayShowCursor(CGMainDisplayID())
        hideCount = 0
    }

    private func startTimer() {
        guard timer == nil else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 120.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateCursorPosition()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func updateCursorPosition() {
        window.updatePosition(to: NSEvent.mouseLocation)
    }
}

private final class CursorOverlayWindow: NSWindow {
    private let label = NSTextField(labelWithString: "")
    private let cursorSize: CGFloat = 20
    private let frameSize = CGSize(width: 28, height: 28)
    private let hotSpot = CGPoint(x: 5, y: 21)

    init() {
        super.init(
            contentRect: CGRect(origin: .zero, size: frameSize),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = true
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]

        let contentView = NSView(frame: CGRect(origin: .zero, size: frameSize))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor

        label.frame = contentView.bounds
        label.alignment = .center
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: cursorSize)

        contentView.addSubview(label)
        self.contentView = contentView
    }

    required init?(coder: NSCoder) {
        nil
    }

    override var canBecomeKey: Bool { false }

    func update(option: CursorOption) {
        label.stringValue = option.emoji
    }

    func updatePosition(to mouseLocation: CGPoint) {
        let origin = CGPoint(x: mouseLocation.x - hotSpot.x, y: mouseLocation.y - hotSpot.y)
        setFrameOrigin(origin)
    }
}
