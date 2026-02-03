//
//  ClipLikeApp.swift
//  ClipLike
//
//  Created by henery on 2026/2/2.
//

import SwiftUI
import AppKit
import ApplicationServices
import os

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
    private var selectionService: SelectionService?
    private var triggerService: TriggerService?
    private let permissionGuide = PermissionGuide()
    private let logger = Logger(subsystem: "ClipLike", category: "App")

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        AccessibilityPermission.requestIfNeeded()
        overlayController = OverlayController()
        selectionService = SelectionService()
        triggerService = TriggerService()
        triggerService?.onInputMonitoringRequired = { [weak self] in
            self?.permissionGuide.promptInputMonitoring()
        }
        triggerService?.onTestHotkey = { [weak self] point in
            DispatchQueue.main.async {
                self?.overlayController?.updateSelection(text: "")
                self?.overlayController?.show(at: point, selectionRect: nil)
            }
        }
        triggerService?.onTrigger = { [weak self] point in
            self?.logger.info("trigger mouseUp at \(point.x), \(point.y)")
            self?.selectionService?.fetchSelection { result in
                switch result {
                case .notTrusted:
                    self?.permissionGuide.promptIfNeeded()
                    self?.logger.info("selection not trusted")
                case .success(let selection):
                    let trimmed = selection.text.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else {
                        self?.logger.info("selection empty after trim")
                        return
                    }
                    self?.logger.info("selection text length \(selection.text.count)")
                    DispatchQueue.main.async {
                        self?.overlayController?.updateSelection(text: selection.text)
                        self?.overlayController?.show(at: point, selectionRect: selection.rect)
                    }
                case .empty:
                    self?.logger.info("selection empty")
                    return
                }
            }
        }
        triggerService?.start()
    }
}

final class AccessibilityPermission {
    static func requestIfNeeded() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }
}

final class PermissionGuide {
    private var hasShown = false
    private var hasShownInputMonitoring = false

    func promptIfNeeded() {
        guard !AXIsProcessTrusted() else { return }
        guard !hasShown else { return }
        hasShown = true
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "需要开启辅助功能权限"
            alert.informativeText = "前往 系统设置 > 隐私与安全性 > 辅助功能，启用 ClipLike"
            alert.addButton(withTitle: "打开系统设置")
            alert.addButton(withTitle: "稍后")
            let response = alert.runModal()
            if response == .alertFirstButtonReturn,
               let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    func promptInputMonitoring() {
        guard !hasShownInputMonitoring else { return }
        hasShownInputMonitoring = true
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "需要开启输入监控权限"
            alert.informativeText = "前往 系统设置 > 隐私与安全性 > 输入监控，启用 ClipLike"
            alert.addButton(withTitle: "打开系统设置")
            alert.addButton(withTitle: "稍后")
            let response = alert.runModal()
            if response == .alertFirstButtonReturn,
               let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}

struct SelectionResult {
    let text: String
    let rect: CGRect?
}

enum SelectionFetchResult {
    case success(SelectionResult)
    case notTrusted
    case empty
}

final class SelectionService {
    private let queue = DispatchQueue(label: "cliplike.selection", qos: .userInitiated)
    private let logger = Logger(subsystem: "ClipLike", category: "Selection")

    func fetchSelection(completion: @escaping (SelectionFetchResult) -> Void) {
        queue.async {
            self.fetchSelectionOnce { result in
                switch result {
                case .success:
                    completion(result)
                case .notTrusted:
                    completion(result)
                case .empty:
                    self.queue.asyncAfter(deadline: .now() + 0.12) {
                        self.fetchSelectionOnce(completion: completion)
                    }
                }
            }
        }
    }

    private func fetchSelectionOnce(completion: @escaping (SelectionFetchResult) -> Void) {
        guard AXIsProcessTrusted() else {
            logger.info("AX not trusted")
            completion(.notTrusted)
            return
        }

        guard let focusedElement = fetchFocusedElement() else {
            logger.info("focus element missing")
            completion(.empty)
            return
        }

        guard let selectedText = fetchSelectedText(from: focusedElement) else {
            logger.info("selectedText missing")
            completion(.empty)
            return
        }

        let rect = fetchSelectionRect(from: focusedElement)
        if rect == nil {
            logger.info("selection rect missing, fallback to mouse")
        }
        completion(.success(SelectionResult(text: selectedText, rect: rect)))
    }

    private func fetchFocusedElement() -> AXUIElement? {
        let systemWide = AXUIElementCreateSystemWide()
        if let focused = copyAttribute(systemWide, attribute: kAXFocusedUIElementAttribute as CFString) {
            return focused
        }
        let frontmost = NSWorkspace.shared.frontmostApplication
        guard let pid = frontmost?.processIdentifier else {
            return nil
        }
        let appElement = AXUIElementCreateApplication(pid)
        if let focused = copyAttribute(appElement, attribute: kAXFocusedUIElementAttribute as CFString) {
            return focused
        }
        return nil
    }

    private func fetchSelectedText(from element: AXUIElement) -> String? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXSelectedTextAttribute as CFString, &value)
        if result == .success, let value {
            if let text = value as? String {
                return text
            }
            if let attributed = value as? NSAttributedString {
                return attributed.string
            }
        }

        logger.info("kAXSelectedTextAttribute missing, trying kAXStringForRangeParameterizedAttribute")
        var rangeValue: CFTypeRef?
        let rangeResult = AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &rangeValue)
        guard rangeResult == .success, let rangeValue else { return nil }

        var stringValue: CFTypeRef?
        let stringResult = AXUIElementCopyParameterizedAttributeValue(
            element,
            kAXStringForRangeParameterizedAttribute as CFString,
            rangeValue,
            &stringValue
        )
        guard stringResult == .success, let stringValue else { return nil }
        if let text = stringValue as? String {
            return text
        }
        if let attributed = stringValue as? NSAttributedString {
            return attributed.string
        }
        return nil
    }

    private func fetchSelectionRect(from element: AXUIElement) -> CGRect? {
        var rangeValue: CFTypeRef?
        let rangeResult = AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &rangeValue)
        guard rangeResult == .success, let range = rangeValue else { return nil }
        var boundsValue: CFTypeRef?
        let boundsResult = AXUIElementCopyParameterizedAttributeValue(
            element,
            kAXBoundsForRangeParameterizedAttribute as CFString,
            range,
            &boundsValue
        )
        guard boundsResult == .success, let boundsValue else { return nil }
        let bounds = boundsValue as! AXValue
        var rectValue = CGRect.zero
        guard AXValueGetValue(bounds, .cgRect, &rectValue) else { return nil }
        return rectValue
    }

    private func copyAttribute(_ element: AXUIElement, attribute: CFString) -> AXUIElement? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute, &value)
        guard result == .success, let value else { return nil }
        guard CFGetTypeID(value) == AXUIElementGetTypeID() else { return nil }
        return unsafeBitCast(value, to: AXUIElement.self)
    }
}

final class TriggerService {
    var onTrigger: ((NSPoint) -> Void)?
    var onInputMonitoringRequired: (() -> Void)?
    var onTestHotkey: ((NSPoint) -> Void)?
    private var globalMonitor: Any?
    private var globalKeyMonitor: Any?
    private var localMonitor: Any?
    private let queue = DispatchQueue(label: "cliplike.trigger", qos: .userInitiated)
    private var pendingWorkItem: DispatchWorkItem?
    private let logger = Logger(subsystem: "ClipLike", category: "Trigger")

    func start() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) { [weak self] _ in
            self?.handleMouseUp()
        }
        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleHotkey(event)
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp, .keyDown]) { [weak self] event in
            self?.handleLocalEvent(event)
            return event
        }
        if globalMonitor == nil {
            logger.info("global mouse monitor unavailable")
            onInputMonitoringRequired?()
        }
        if globalKeyMonitor == nil {
            logger.info("global key monitor unavailable")
            onInputMonitoringRequired?()
        }
    }

    private func handleMouseUp() {
        let point = NSEvent.mouseLocation
        logger.info("mouseUp event \(point.x), \(point.y)")
        pendingWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.onTrigger?(point)
        }
        pendingWorkItem = workItem
        queue.asyncAfter(deadline: .now() + 0.05, execute: workItem)
    }

    private func handleLocalEvent(_ event: NSEvent) {
        if event.type == .leftMouseUp {
            handleMouseUp()
            return
        }
        if event.type == .keyDown {
            handleHotkey(event)
        }
    }

    private func handleHotkey(_ event: NSEvent) {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if modifiers.contains([.command, .shift]) && event.keyCode == 49 {
            logger.info("hotkey triggered")
            onTestHotkey?(NSEvent.mouseLocation)
        }
    }
}

final class OverlayController {
    private let panel: NSPanel
    private let viewSize = NSSize(width: 280, height: 44)
    private let selectionStore: SelectionStore

    init() {
        let selectionStore = SelectionStore()
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
                    let text = OverlayController.currentText(from: selectionStore)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                    panel?.orderOut(nil)
                },
                onSearch: { [weak panel] in
                    let text = OverlayController.currentText(from: selectionStore)
                    let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "https://www.google.com/search?q=\(encoded)") {
                        NSWorkspace.shared.open(url)
                    }
                    panel?.orderOut(nil)
                },
                onBob: { [weak panel] in
                    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.hezongyidev.Bob")
                        ?? NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.ripperhe.Bob") {
                        let configuration = NSWorkspace.OpenConfiguration()
                        NSWorkspace.shared.openApplication(at: url, configuration: configuration, completionHandler: nil)
                    } else if let appUrl = URL(string: "file:///Applications/Bob.app") {
                        NSWorkspace.shared.open(appUrl)
                    }
                    panel?.orderOut(nil)
                }
            )
        )
        hostingView.frame = NSRect(origin: .zero, size: viewSize)
        panel.contentView = hostingView

        self.panel = panel
        self.selectionStore = selectionStore
    }

    func updateSelection(text: String) {
        selectionStore.text = text
    }

    func show(at point: NSPoint, selectionRect: CGRect?) {
        let anchorPoint = selectionRect.map { NSPoint(x: $0.midX, y: $0.minY) } ?? point
        let screen = NSScreen.screens.first(where: { $0.frame.contains(anchorPoint) }) ?? NSScreen.main
        let visibleFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        var origin = NSPoint(x: anchorPoint.x - viewSize.width / 2, y: anchorPoint.y - viewSize.height - 12)
        origin.x = max(visibleFrame.minX + 8, min(origin.x, visibleFrame.maxX - viewSize.width - 8))
        origin.y = max(visibleFrame.minY + 8, min(origin.y, visibleFrame.maxY - viewSize.height - 8))
        panel.setFrame(NSRect(origin: origin, size: viewSize), display: true)
        panel.orderFront(nil)
    }

    private static func currentText(from selectionStore: SelectionStore) -> String {
        let trimmed = selectionStore.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            return trimmed
        }
        return NSPasteboard.general.string(forType: .string) ?? ""
    }
}

final class SelectionStore {
    var text: String = ""
}
