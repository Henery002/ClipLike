//
//  ClipLikeApp.swift
//  ClipLike
//
//  Created by henery on 2026/2/2.
//

import SwiftUI
import AppKit
import ApplicationServices
import Combine
import os

struct ActionSetting: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var icon: String
    var isOn: Bool
    var showsGear: Bool
}

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    @Published var autoShow: Bool { didSet { defaults.set(autoShow, forKey: Keys.autoShow) } }
    @Published var overlaySize: Double { didSet { defaults.set(overlaySize, forKey: Keys.overlaySize) } }
    @Published var colorMode: String { didSet { defaults.set(colorMode, forKey: Keys.colorMode) } }
    @Published var positionMode: String { didSet { defaults.set(positionMode, forKey: Keys.positionMode) } }
    @Published var launchAtLogin: Bool { didSet { defaults.set(launchAtLogin, forKey: Keys.launchAtLogin) } }
    @Published var showMenuBar: Bool { didSet { defaults.set(showMenuBar, forKey: Keys.showMenuBar) } }
    @Published var actions: [ActionSetting] { didSet { saveActions() } }

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.autoShow = defaults.object(forKey: Keys.autoShow) as? Bool ?? true
        self.overlaySize = defaults.object(forKey: Keys.overlaySize) as? Double ?? 0.6
        self.colorMode = defaults.string(forKey: Keys.colorMode) ?? "自动显示"
        self.positionMode = defaults.string(forKey: Keys.positionMode) ?? "文本上方"
        self.launchAtLogin = defaults.object(forKey: Keys.launchAtLogin) as? Bool ?? true
        self.showMenuBar = defaults.object(forKey: Keys.showMenuBar) as? Bool ?? true
        self.actions = SettingsStore.loadActions(from: defaults) ?? SettingsStore.defaultActions
    }

    private func saveActions() {
        guard let data = try? JSONEncoder().encode(actions) else { return }
        defaults.set(data, forKey: Keys.actions)
    }

    private static func loadActions(from defaults: UserDefaults) -> [ActionSetting]? {
        guard let data = defaults.data(forKey: Keys.actions) else { return nil }
        return try? JSONDecoder().decode([ActionSetting].self, from: data)
    }

    private static var defaultActions: [ActionSetting] {
        [
            ActionSetting(id: "openLink", title: "打开链接", icon: "link", isOn: true, showsGear: true),
            ActionSetting(id: "search", title: "搜索", icon: "magnifyingglass", isOn: true, showsGear: true),
            ActionSetting(id: "cut", title: "剪切", icon: "scissors", isOn: false, showsGear: true),
            ActionSetting(id: "copy", title: "拷贝", icon: "doc.on.doc", isOn: true, showsGear: false),
            ActionSetting(id: "bob", title: "Bob", icon: "character.bubble", isOn: true, showsGear: true),
            ActionSetting(id: "localRAG", title: "LocalRAG Hub", icon: "bolt.horizontal.circle", isOn: false, showsGear: true)
        ]
    }

    private enum Keys {
        static let autoShow = "settings.autoShow"
        static let overlaySize = "settings.overlaySize"
        static let colorMode = "settings.colorMode"
        static let positionMode = "settings.positionMode"
        static let launchAtLogin = "settings.launchAtLogin"
        static let showMenuBar = "settings.showMenuBar"
        static let actions = "settings.actions"
    }
}

@main
struct ClipLikeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(SettingsStore.shared)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    static weak var shared: AppDelegate?
    private var overlayController: OverlayController?
    private var selectionService: SelectionService?
    private var triggerService: TriggerService?
    private let permissionGuide = PermissionGuide()
    private let logger = Logger(subsystem: "ClipLike", category: "App")
    private var settingsWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        NSApplication.shared.setActivationPolicy(.accessory)
        AccessibilityPermission.requestIfNeeded()
        selectionService = SelectionService()
        overlayController = OverlayController(
            selectionService: selectionService ?? SelectionService(),
            onOpenSettings: { [weak self] in
                self?.openSettingsWindow()
            }
        )
        triggerService = TriggerService()
        triggerService?.onInputMonitoringRequired = { [weak self] in
            self?.permissionGuide.promptInputMonitoring()
        }
        triggerService?.onMouseDown = { [weak self] in
            DispatchQueue.main.async {
                self?.overlayController?.hide()
            }
        }
        triggerService?.onTestHotkey = { [weak self] point in
            self?.handleTrigger(at: point, reason: "hotkey")
        }
        triggerService?.onTrigger = { [weak self] point in
            self?.handleTrigger(at: point, reason: "mouseUp")
        }
        triggerService?.start()

#if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                return
            }
            self?.openSettingsWindow()
        }
#endif
    }

    func openSettingsWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let existing = settingsWindowController?.window {
            existing.makeKeyAndOrderFront(nil)
            return
        }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 480),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "ClipLike"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentView = NSHostingView(rootView: SettingsView().environmentObject(SettingsStore.shared))
        let controller = NSWindowController(window: window)
        settingsWindowController = controller
        controller.showWindow(nil)
        window.makeKeyAndOrderFront(nil)
    }

    private func handleTrigger(at point: NSPoint, reason: String) {
        if reason == "mouseUp", SettingsStore.shared.autoShow == false {
            logger.info("autoShow off, ignore mouseUp trigger")
            return
        }
        logger.info("trigger \(reason) at \(point.x), \(point.y)")
        selectionService?.fetchSelection { [weak self] result in
            switch result {
            case .notTrusted:
                self?.permissionGuide.promptIfNeeded()
                self?.logger.info("selection not trusted")
            case .success(let selection), .clipboard(let selection):
                let trimmed = selection.text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    self?.logger.info("selection empty after trim")
                    return
                }
                self?.logger.info("showing overlay; source: \(self?.describeResultType(result) ?? "unknown"), length: \(selection.text.count)")
                DispatchQueue.main.async {
                    self?.overlayController?.updateSelection(text: selection.text)
                    self?.overlayController?.show(at: point, selectionRect: selection.rect)
                }
            case .empty:
                self?.logger.info("selection empty (all methods failed)")
#if DEBUG
                if reason == "hotkey" {
                    DispatchQueue.main.async {
                        self?.overlayController?.show(at: point, selectionRect: nil)
                    }
                }
#endif
            }
        }
    }

    private func describeResultType(_ result: SelectionFetchResult) -> String {
        switch result {
        case .success: return "AX"
        case .clipboard: return "Clipboard"
        default: return "None"
        }
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
    case clipboard(SelectionResult)
    case notTrusted
    case empty
}

final class SelectionService {
    private let queue = DispatchQueue(label: "cliplike.selection", qos: .userInitiated)
    private let logger = Logger(subsystem: "ClipLike", category: "Selection")

    func fetchSelection(completion: @escaping (SelectionFetchResult) -> Void) {
        queue.async {
            self.fetchSelectionOnce(attempt: 0, completion: completion)
        }
    }

    private func fetchSelectionOnce(attempt: Int, completion: @escaping (SelectionFetchResult) -> Void) {
        guard AXIsProcessTrusted() else {
            logger.info("AX not trusted")
            completion(.notTrusted)
            return
        }

        if let focusedElement = fetchFocusedElement() {
            if let selectedText = fetchSelectedText(from: focusedElement) {
                let rect = fetchSelectionRect(from: focusedElement)
                if rect == nil {
                    logger.info("selection rect missing, fallback to mouse; focused: \(self.elementSummary(focusedElement))")
                }
                completion(.success(SelectionResult(text: selectedText, rect: rect)))
                return
            } else {
                logger.info("selectedText missing; focused: \(self.elementSummary(focusedElement))")
            }
        } else {
            logger.info("focus element missing; frontmost: \(self.frontmostAppSummary())")
        }

        // AX 失败后的重试
        if attempt < 2 {
            let delay = 0.05 + (Double(attempt) * 0.05)
            queue.asyncAfter(deadline: .now() + delay) {
                self.fetchSelectionOnce(attempt: attempt + 1, completion: completion)
            }
            return
        }

        // 最终失败，尝试剪贴板兜底
        if let clipboardText = NSPasteboard.general.string(forType: .string), !clipboardText.isEmpty {
            logger.info("AX failed, fallback to clipboard (length: \(clipboardText.count))")
            completion(.clipboard(SelectionResult(text: clipboardText, rect: nil)))
        } else {
            logger.info("AX and clipboard both failed")
            completion(.empty)
        }
    }

    private func fetchFocusedElement() -> AXUIElement? {
        let systemWide = AXUIElementCreateSystemWide()
        let (systemFocused, systemResult) = copyAXElement(systemWide, attribute: kAXFocusedUIElementAttribute as CFString)
        if let systemFocused {
            return systemFocused
        }
        logger.info("systemWide focused failed: \(self.describeAXError(systemResult))")

        let (focusedApp, focusedAppResult) = copyAXElement(systemWide, attribute: kAXFocusedApplicationAttribute as CFString)
        if let focusedApp {
            let (focusedFromApp, focusedFromAppResult) = copyAXElement(focusedApp, attribute: kAXFocusedUIElementAttribute as CFString)
            if let focusedFromApp {
                return focusedFromApp
            }
            logger.info("focused app element failed: \(self.describeAXError(focusedFromAppResult))")
            let (windowFromApp, windowFromAppResult) = copyAXElement(focusedApp, attribute: kAXFocusedWindowAttribute as CFString)
            if let windowFromApp {
                let (focusedFromWindow, focusedFromWindowResult) = copyAXElement(windowFromApp, attribute: kAXFocusedUIElementAttribute as CFString)
                if let focusedFromWindow {
                    return focusedFromWindow
                }
                logger.info("focused app window element failed: \(self.describeAXError(focusedFromWindowResult))")
            } else {
                logger.info("focused app window failed: \(self.describeAXError(windowFromAppResult))")
            }
        } else {
            logger.info("focused application failed: \(self.describeAXError(focusedAppResult))")
        }

        let frontmost = NSWorkspace.shared.frontmostApplication
        let frontmostBundleID = frontmost?.bundleIdentifier ?? ""
        guard let pid = frontmost?.processIdentifier else {
            return nil
        }
        let appElement = AXUIElementCreateApplication(pid)
        let (appFocused, appResult) = copyAXElement(appElement, attribute: kAXFocusedUIElementAttribute as CFString)
        if let appFocused {
            return appFocused
        }
        logger.info("app focused failed: \(self.describeAXError(appResult)); pid=\(pid), bundleID=\(frontmostBundleID)")
        let (windowFromApp, windowResult) = copyAXElement(appElement, attribute: kAXFocusedWindowAttribute as CFString)
        if let windowFromApp {
            let (focusedFromWindow, windowFocusedResult) = copyAXElement(windowFromApp, attribute: kAXFocusedUIElementAttribute as CFString)
            if let focusedFromWindow {
                return focusedFromWindow
            }
            logger.info("window focused failed: \(self.describeAXError(windowFocusedResult)); pid=\(pid), bundleID=\(frontmostBundleID)")
        } else {
            logger.info("focused window failed: \(self.describeAXError(windowResult)); pid=\(pid), bundleID=\(frontmostBundleID)")
        }

        let (systemWindow, systemWindowResult) = copyAXElement(systemWide, attribute: kAXFocusedWindowAttribute as CFString)
        if let systemWindow {
            let (focusedFromWindow, systemWindowFocusedResult) = copyAXElement(systemWindow, attribute: kAXFocusedUIElementAttribute as CFString)
            if let focusedFromWindow {
                return focusedFromWindow
            }
            logger.info("system window focused failed: \(self.describeAXError(systemWindowFocusedResult))")
        } else {
            logger.info("system focused window failed: \(self.describeAXError(systemWindowResult))")
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
            logger.info("kAXSelectedTextAttribute unexpected typeID=\(CFGetTypeID(value)); focused: \(self.elementSummary(element))")
        } else {
            logger.info("kAXSelectedTextAttribute failed: \(self.describeAXError(result)); focused: \(self.elementSummary(element))")
        }

        logger.info("kAXSelectedTextAttribute missing, trying kAXStringForRangeParameterizedAttribute")
        var rangeValue: CFTypeRef?
        let rangeResult = AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &rangeValue)
        guard rangeResult == .success, let rangeValue else {
            logger.info("kAXSelectedTextRangeAttribute failed: \(self.describeAXError(rangeResult)); focused: \(self.elementSummary(element))")
            return nil
        }

        var stringValue: CFTypeRef?
        let stringResult = AXUIElementCopyParameterizedAttributeValue(
            element,
            kAXStringForRangeParameterizedAttribute as CFString,
            rangeValue,
            &stringValue
        )
        guard stringResult == .success, let stringValue else {
            logger.info("kAXStringForRangeParameterizedAttribute failed: \(self.describeAXError(stringResult)); focused: \(self.elementSummary(element))")
            return nil
        }
        if let text = stringValue as? String {
            return text
        }
        if let attributed = stringValue as? NSAttributedString {
            return attributed.string
        }
        logger.info("kAXStringForRangeParameterizedAttribute unexpected typeID=\(CFGetTypeID(stringValue)); focused: \(self.elementSummary(element))")
        return nil
    }

    private func fetchSelectionRect(from element: AXUIElement) -> CGRect? {
        var rangeValue: CFTypeRef?
        let rangeResult = AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &rangeValue)
        guard rangeResult == .success, let range = rangeValue else {
            logger.info("kAXSelectedTextRangeAttribute for rect failed: \(self.describeAXError(rangeResult)); focused: \(self.elementSummary(element))")
            return nil
        }
        var boundsValue: CFTypeRef?
        let boundsResult = AXUIElementCopyParameterizedAttributeValue(
            element,
            kAXBoundsForRangeParameterizedAttribute as CFString,
            range,
            &boundsValue
        )
        guard boundsResult == .success, let boundsValue else {
            logger.info("kAXBoundsForRangeParameterizedAttribute failed: \(self.describeAXError(boundsResult)); focused: \(self.elementSummary(element))")
            return nil
        }
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

    private func copyAXElement(_ element: AXUIElement, attribute: CFString) -> (AXUIElement?, AXError) {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute, &value)
        guard result == .success, let value, CFGetTypeID(value) == AXUIElementGetTypeID() else {
            return (nil, result)
        }
        return (unsafeBitCast(value, to: AXUIElement.self), result)
    }

    private func frontmostAppSummary() -> String {
        let frontmost = NSWorkspace.shared.frontmostApplication
        let bundleID = frontmost?.bundleIdentifier ?? ""
        let name = frontmost?.localizedName ?? ""
        let pid = frontmost?.processIdentifier ?? 0
        return "name=\(name), bundleID=\(bundleID), pid=\(pid)"
    }

    private func elementSummary(_ element: AXUIElement) -> String {
        let role = copyStringAttribute(element, attribute: kAXRoleAttribute as CFString) ?? ""
        let subrole = copyStringAttribute(element, attribute: kAXSubroleAttribute as CFString) ?? ""
        return "role=\(role), subrole=\(subrole)"
    }

    private func copyStringAttribute(_ element: AXUIElement, attribute: CFString) -> String? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute, &value)
        guard result == .success, let value else { return nil }
        return value as? String
    }

    private func describeAXError(_ error: AXError) -> String {
        switch error {
        case .success: return "success"
        case .failure: return "failure"
        case .illegalArgument: return "illegalArgument"
        case .invalidUIElement: return "invalidUIElement"
        case .invalidUIElementObserver: return "invalidUIElementObserver"
        case .cannotComplete: return "cannotComplete"
        case .attributeUnsupported: return "attributeUnsupported"
        case .actionUnsupported: return "actionUnsupported"
        case .notificationUnsupported: return "notificationUnsupported"
        case .notImplemented: return "notImplemented"
        case .notificationAlreadyRegistered: return "notificationAlreadyRegistered"
        case .notificationNotRegistered: return "notificationNotRegistered"
        case .apiDisabled: return "apiDisabled"
        case .noValue: return "noValue"
        case .parameterizedAttributeUnsupported: return "parameterizedAttributeUnsupported"
        case .notEnoughPrecision: return "notEnoughPrecision"
        @unknown default: return "unknown"
        }
    }
}

final class TriggerService {
    var onTrigger: ((NSPoint) -> Void)?
    var onInputMonitoringRequired: (() -> Void)?
    var onTestHotkey: ((NSPoint) -> Void)?
    var onMouseDown: (() -> Void)?
    
    private var globalMonitor: Any?
    private var globalKeyMonitor: Any?
    private var globalDownMonitor: Any?
    private var localMonitor: Any?
    
    private let queue = DispatchQueue(label: "cliplike.trigger", qos: .userInitiated)
    private var pendingWorkItem: DispatchWorkItem?
    private var mouseDownPoint: NSPoint?
    private let dragThreshold: CGFloat = 5.0
    private let logger = Logger(subsystem: "ClipLike", category: "Trigger")

    func start() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) { [weak self] _ in
            self?.handleMouseUp()
        }
        globalDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] _ in
            self?.handleMouseDown()
        }
        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleHotkey(event)
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleHotkey(event)
            return event
        }
        if globalMonitor == nil || globalDownMonitor == nil {
            logger.info("global mouse monitor unavailable")
            onInputMonitoringRequired?()
        }
        if globalKeyMonitor == nil {
            logger.info("global key monitor unavailable")
            onInputMonitoringRequired?()
        }
    }

    private func handleMouseDown() {
        mouseDownPoint = NSEvent.mouseLocation
        onMouseDown?()
    }

    private func handleMouseUp() {
        let point = NSEvent.mouseLocation
        
        // 只有当存在拖拽位移时才认为是选区行为
        if let startPoint = mouseDownPoint {
            let dx = point.x - startPoint.x
            let dy = point.y - startPoint.y
            let distance = sqrt(dx*dx + dy*dy)
            
            if distance < dragThreshold {
                logger.info("mouseUp ignored: distance \(distance) < threshold")
                mouseDownPoint = nil
                return
            }
            logger.info("mouseUp trigger: distance \(distance)")
        } else {
            // 如果没拿到 mouseDown（比如权限问题或启动瞬间），保守起见不触发
            return
        }
        
        mouseDownPoint = nil
        pendingWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.onTrigger?(point)
        }
        pendingWorkItem = workItem
        queue.asyncAfter(deadline: .now() + 0.05, execute: workItem)
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
    private static let buttonWidth: CGFloat = 40
    private static let buttonPaddingX: CGFloat = 4
    private static let viewHeight: CGFloat = 40
    private static let buttonCount: CGFloat = 5
    private static let copyButtonIndex: CGFloat = 2
    private static let yOffset: CGFloat = 6
    private let viewSize = NSSize(
        width: (buttonCount * buttonWidth) + (buttonPaddingX * 2),
        height: viewHeight
    )
    private let selectionStore: SelectionStore
    private let selectionService: SelectionService

    init(selectionService: SelectionService, onOpenSettings: @escaping () -> Void) {
        let selectionStore = SelectionStore()
        let selectionServiceRef = selectionService
        let logger = Logger(subsystem: "ClipLike", category: "Overlay")
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
                onAppIcon: {
                    onOpenSettings()
                    panel.orderOut(nil)
                },
                onSearch: { [weak panel] in
                    OverlayController.performSearch(selectionService: selectionServiceRef, selectionStore: selectionStore, logger: logger)
                    panel?.orderOut(nil)
                },
                onCopy: { [weak panel] in
                    OverlayController.performCopy(selectionService: selectionServiceRef, selectionStore: selectionStore, logger: logger)
                    panel?.orderOut(nil)
                },
                onBob: { [weak panel] in
                    OverlayController.performBob(logger: logger)
                    panel?.orderOut(nil)
                },
                onRagHub: { [weak panel] in
                    OverlayController.performRagHubShortcut()
                    panel?.orderOut(nil)
                }
            )
        )
        hostingView.frame = NSRect(origin: .zero, size: viewSize)
        panel.contentView = hostingView

        self.panel = panel
        self.selectionStore = selectionStore
        self.selectionService = selectionService
    }

    func updateSelection(text: String) {
        selectionStore.text = text
    }

    func show(at point: NSPoint, selectionRect: CGRect?) {
        let logger = Logger(subsystem: "ClipLike", category: "Overlay")
        let anchorPoint = point
        let screen = NSScreen.screens.first(where: { $0.frame.contains(anchorPoint) }) ?? NSScreen.main
        let visibleFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let copyCenterX = Self.buttonPaddingX + (Self.buttonWidth * (Self.copyButtonIndex + 0.5))
        var origin = NSPoint(x: anchorPoint.x - copyCenterX, y: anchorPoint.y - viewSize.height - Self.yOffset)
        origin.x = max(visibleFrame.minX + 8, min(origin.x, visibleFrame.maxX - viewSize.width - 8))
        origin.y = max(visibleFrame.minY + 8, min(origin.y, visibleFrame.maxY - viewSize.height - 8))
        
        logger.info("Panel showing at \(origin.x), \(origin.y) (anchor: \(anchorPoint.x), \(anchorPoint.y))")
        panel.setFrame(NSRect(origin: origin, size: viewSize), display: true)
        panel.orderFrontRegardless()
    }

    func hide() {
        panel.orderOut(nil)
    }

    private static func currentText(from selectionStore: SelectionStore) -> String {
        let trimmed = selectionStore.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            return trimmed
        }
        return NSPasteboard.general.string(forType: .string) ?? ""
    }

    private static func performCopy(selectionService: SelectionService, selectionStore: SelectionStore, logger: Logger) {
        selectionService.fetchSelection { result in
            let text = OverlayController.text(from: result, fallback: selectionStore.text)
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            DispatchQueue.main.async {
                selectionStore.text = trimmed
                NSPasteboard.general.clearContents()
                let ok = NSPasteboard.general.setString(trimmed, forType: .string)
                logger.info("copy ok=\(ok), length=\(trimmed.count)")
            }
        }
    }

    private static func performSearch(selectionService: SelectionService, selectionStore: SelectionStore, logger: Logger) {
        selectionService.fetchSelection { result in
            let text = OverlayController.text(from: result, fallback: selectionStore.text)
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "https://www.google.com/search?q=\(encoded)") {
                DispatchQueue.main.async {
                    selectionStore.text = trimmed
                    NSWorkspace.shared.open(url)
                    logger.info("search length=\(trimmed.count)")
                }
            }
        }
    }

    private static func performBob(logger: Logger) {
        DispatchQueue.main.async {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.hezongyidev.Bob")
                ?? NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.ripperhe.Bob") {
                let configuration = NSWorkspace.OpenConfiguration()
                NSWorkspace.shared.openApplication(at: url, configuration: configuration, completionHandler: nil)
            } else if let appUrl = URL(string: "file:///Applications/Bob.app") {
                NSWorkspace.shared.open(appUrl)
            }
            logger.info("bob open invoked")
        }
    }

    private static func performRagHubShortcut() {
        DispatchQueue.main.async {
            guard let source = CGEventSource(stateID: .combinedSessionState) else { return }
            let keyCodeK: CGKeyCode = 40
            guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCodeK, keyDown: true),
                  let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCodeK, keyDown: false) else { return }
            keyDown.flags = .maskCommand
            keyUp.flags = .maskCommand
            keyDown.post(tap: .cghidEventTap)
            keyUp.post(tap: .cghidEventTap)
        }
    }

    private static func text(from result: SelectionFetchResult, fallback: String) -> String {
        switch result {
        case .success(let selection), .clipboard(let selection):
            return selection.text
        default:
            return fallback
        }
    }
}

final class SelectionStore {
    var text: String = ""
}
