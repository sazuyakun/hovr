//
//  hovrApp.swift
//  hovr
//
//  Created by Soham Samal on 15/03/26.
//

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct hovrApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var cursorManager = CursorManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cursorManager)
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
                    cursorManager.restoreSystemCursor()
                }
        }
        .windowResizability(.contentSize)

        MenuBarExtra("Hovr", systemImage: "cursorarrow.motionlines") {
            HStack(spacing: 8) {
                ForEach(CursorOption.allCases) { option in
                    Button {
                        cursorManager.apply(option)
                    } label: {
                        CursorPreview(option: option, size: 18)
                            .frame(width: 34, height: 34)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(nsColor: .controlBackgroundColor))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
        }
        .menuBarExtraStyle(.window)
    }
}
