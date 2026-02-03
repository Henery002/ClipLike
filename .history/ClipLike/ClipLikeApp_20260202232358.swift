//
//  ClipLikeApp.swift
//  ClipLike
//
//  Created by henery on 2026/2/2.
//

import SwiftUI
import AppKit

@main
struct ClipLikeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlayController: OverlayController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        overlayController = OverlayController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.overlayController?.show(at: NSEvent.mouseLocation)
        }
    }
}

final class OverlayController {
    private let panel: NSPanel
    private let viewSize = NSSize(width: 280, height: 44)

    init() {
        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: viewSize),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovable = false
        panel.ignoresMouseEvents = false

        let hostingView = NSHostingView(
            rootView: OverlayView(
                onCopy: { [weak panel] in
                    let text = OverlayController.currentText()
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                    panel?.orderOut(nil)
                },
                onSearch: { [weak panel] in
                    let text = OverlayController.currentText()
                    let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "https://www.google.com/search?q=\(encoded)") {
                        NSWorkspace.shared.open(url)
                    }
                    panel?.orderOut(nil)
                },
                onBob: { [weak panel] in
                    NSWorkspace.shared.launchApplication("Bob")
                    panel?.orderOut(nil)
                }
            )
        )
        hostingView.frame = NSRect(origin: .zero, size: viewSize)
        panel.contentView = hostingView

        self.panel = panel
    }

    func show(at point: NSPoint) {
        let screen = NSScreen.screens.first(where: { $0.frame.contains(point) }) ?? NSScreen.main
        let visibleFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        var origin = NSPoint(x: point.x - viewSize.width / 2, y: point.y - viewSize.height - 12)
        origin.x = max(visibleFrame.minX + 8, min(origin.x, visibleFrame.maxX - viewSize.width - 8))
        origin.y = max(visibleFrame.minY + 8, min(origin.y, visibleFrame.maxY - viewSize.height - 8))
        panel.setFrame(NSRect(origin: origin, size: viewSize), display: true)
        panel.orderFront(nil)
    }

    private static func currentText() -> String {
        let text = NSPasteboard.general.string(forType: .string) ?? ""
        return text.isEmpty ? "ClipLike" : text
    }
}
