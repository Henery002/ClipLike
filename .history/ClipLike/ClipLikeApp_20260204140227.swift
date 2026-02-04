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
    var selectionService: SelectionService?
    private var triggerService: TriggerService?
    private let permissionGuide = PermissionGuide()
    private let logger = Logger(subsystem: "ClipLike", category: "App")
    private var settingsWindowController: NSWindowController?
    private var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        setupStatusItem()
        setupBindings()
        
        let isRunningTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        if isRunningTests {
            NSApplication.shared.setActivationPolicy(.regular)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.openSettingsWindow()
            }
            return
        }
        NSApplication.shared.setActivationPolicy(.accessory)
        AccessibilityPermission.requestIfNeeded()
        selectionService = SelectionService()
        overlayController = OverlayController(
            selectionService: selectionService ?? SelectionService()
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
            // 调试模式下也不自动打开设置窗口，避免干扰
            // self?.openSettingsWindow()
        }
#endif
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            // 尝试加载 AppIcon 并调整大小适配状态栏
            if let appIcon = NSImage(named: "AppIcon") {
                let size = NSSize(width: 18, height: 18)
                let resizedIcon = NSImage(size: size, flipped: false) { rect in
                    appIcon.draw(in: rect)
                    return true
                }
                // 如果是彩色图标，通常不设为 template；如果是单色图标，设为 template 可以适配深色模式
                // 这里假设是 AppIcon 原图，保持原色
                resizedIcon.isTemplate = false
                button.image = resizedIcon
            } else {
                button.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: nil)
            }
        }
        
        setupMenu()
        
        // 初始可见性
        statusItem?.isVisible = SettingsStore.shared.showMenuBar
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        let settingsItem = NSMenuItem(title: "设置...", action: #selector(openSettingsWindow), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let restartItem = NSMenuItem(title: "重新启动", action: #selector(restartApp), keyEquivalent: "")
        restartItem.target = self
        menu.addItem(restartItem)
        
        let quitItem = NSMenuItem(title: "退出 ClipLike", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func restartApp() {
        let url = Bundle.main.bundleURL
        let config = NSWorkspace.OpenConfiguration()
        config.createsNewApplicationInstance = true
        
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, _ in
            DispatchQueue.main.async {
                NSApp.terminate(nil)
            }
        }
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    private func setupBindings() {
        // 绑定菜单栏图标显示设置
        SettingsStore.shared.$showMenuBar
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                self?.statusItem?.isVisible = show
            }
            .store(in: &cancellables)
            
        // 绑定登录自启动设置
        SettingsStore.shared.$launchAtLogin
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.updateLaunchAtLogin(enabled: enabled)
            }
            .store(in: &cancellables)
            
        // 初始同步一次 Launch at Login 状态
        updateLaunchAtLogin(enabled: SettingsStore.shared.launchAtLogin)
    }
    
    private func updateLaunchAtLogin(enabled: Bool) {
        // 由于 App Sandbox 已禁用（为了支持 Bob AppleScript），SMAppService 可能无法正常工作。
        // 这里采用写入 ~/Library/LaunchAgents/plist 的方式作为替代方案。
        
        let bundleID = Bundle.main.bundleIdentifier ?? "com.henery.cliplike"
        let plistName = "\(bundleID).plist"
        
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            logger.error("Failed to find Library directory")
            return
        }
        
        let launchAgentsURL = libraryURL.appendingPathComponent("LaunchAgents")
        let plistURL = launchAgentsURL.appendingPathComponent(plistName)
        
        if enabled {
            do {
                // 确保 LaunchAgents 目录存在
                try FileManager.default.createDirectory(at: launchAgentsURL, withIntermediateDirectories: true, attributes: nil)
                
                // 获取当前可执行文件路径
                // 注意：如果 App 移动位置，此路径会失效，需要重新切换开关更新
                guard let execPath = Bundle.main.executablePath else {
                    logger.error("Failed to get executable path")
                    return
                }
                
                let plistContent = """
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                <dict>
                    <key>Label</key>
                    <string>\(bundleID)</string>
                    <key>ProgramArguments</key>
                    <array>
                        <string>\(execPath)</string>
                    </array>
                    <key>RunAtLoad</key>
                    <true/>
                    <key>ProcessType</key>
                    <string>Interactive</string>
                    <key>KeepAlive</key>
                    <false/>
                </dict>
                </plist>
                """
                
                try plistContent.write(to: plistURL, atomically: true, encoding: .utf8)
                logger.info("Launch Agent plist created at \(plistURL.path)")
                
            } catch {
                logger.error("Failed to create Launch Agent: \(error)")
            }
        } else {
            do {
                if FileManager.default.fileExists(atPath: plistURL.path) {
                    try FileManager.default.removeItem(at: plistURL)
                    logger.info("Launch Agent plist removed")
                }
            } catch {
                logger.error("Failed to remove Launch Agent: \(error)")
            }
        }
    }
    
    @objc private func statusItemClicked() {
        openSettingsWindow()
    }
    
    // 保留此方法作为 openSettingsWindow 的别名或用于其他潜在调用，
    // 虽然 statusItemClicked 不再被 statusItem 直接调用（因为设置了 menu），
    // 但如果有其他地方用到可以保留。
    // 在这里直接删除 statusItemClicked，因为它只被 setupStatusItem 用过。
    
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
        let isMouseTrigger = reason == "mouseUp"
        let delay: TimeInterval = isMouseTrigger ? 0.12 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            self.selectionService?.fetchSelection { [weak self] result in
                guard let self else { return }
            switch result {
            case .notTrusted:
                self.permissionGuide.promptIfNeeded()
                self.logger.info("selection not trusted")
                DispatchQueue.main.async {
                    self.overlayController?.hide()
                }
            case .success(let selection):
                let trimmed = selection.text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    self.logger.info("selection empty after trim")
                    DispatchQueue.main.async {
                        self.overlayController?.hide()
                    }
                    return
                }
                self.logger.info("showing overlay; source: \(self.describeResultType(result)), length: \(selection.text.count)")
                DispatchQueue.main.async {
                    self.overlayController?.updateSelection(text: selection.text)
                    self.overlayController?.show(at: point, selectionRect: selection.rect)
                }
            case .clipboard(let selection):
                let trimmed = selection.text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    self.logger.info("selection empty after trim")
                    DispatchQueue.main.async {
                        self.overlayController?.hide()
                    }
                    return
                }
                self.logger.info("showing overlay; source: \(self.describeResultType(result)), length: \(selection.text.count)")
                DispatchQueue.main.async {
                    self.overlayController?.updateSelection(text: selection.text)
                    self.overlayController?.show(at: point, selectionRect: selection.rect)
                }
            case .empty:
                self.logger.info("selection empty (all methods failed)")
#if DEBUG
                if reason == "hotkey" {
                    DispatchQueue.main.async {
                        self.overlayController?.show(at: point, selectionRect: nil)
                    }
                } else {
                    // 如果是鼠标拖拽触发，且 AX 失败，依然显示 Overlay（允许后续点击按钮时进行主动捕获）
                    if reason == "mouseUp" {
                         self.logger.info("showing overlay (empty text) for mouseUp fallback")
                         DispatchQueue.main.async {
                             self.overlayController?.updateSelection(text: "")
                             self.overlayController?.show(at: point, selectionRect: nil)
                         }
                    } else {
                        DispatchQueue.main.async {
                            self.overlayController?.hide()
                        }
                    }
                }
#else
                if reason == "mouseUp" {
                     self.logger.info("showing overlay (empty text) for mouseUp fallback")
                     DispatchQueue.main.async {
                         self.overlayController?.updateSelection(text: "")
                         self.overlayController?.show(at: point, selectionRect: nil)
                     }
                } else {
                    DispatchQueue.main.async {
                        self.overlayController?.hide()
                    }
                }
#endif
            }
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
            let delay = 0.05
            queue.asyncAfter(deadline: .now() + delay) {
                self.fetchSelectionOnce(attempt: attempt + 1, completion: completion)
            }
            return
        }

        // AX 彻底失败，直接返回 empty，不进行剪贴板读取（避免读取旧数据）也不进行模拟复制（避免干扰用户）
        logger.info("AX failed after retries")
        completion(.empty)
    }

    /// 主动捕获：模拟 Cmd+C 并读取剪贴板
    /// - Parameter restore: 是否在读取后恢复剪贴板内容（避免污染）
    func activeCapture(restore: Bool = false, completion: @escaping (String?) -> Void) {
        let currentChangeCount = NSPasteboard.general.changeCount
        
        // 如果需要恢复，先保存当前剪贴板内容
        // 保存所有 items 比较复杂，且 writeObjects 只能恢复支持的类型。
        // 这里采用保存 pasteboardItems 的方式，这是最接近无损还原的方法。
        var savedItems: [NSPasteboardItem]?
        if restore {
            savedItems = NSPasteboard.general.pasteboardItems?.map { $0.copy() as! NSPasteboardItem }
        }
        
        simulateCopy()
        
        // 等待剪贴板更新
        // 增加延时到 0.25s 以确保复制完成
        queue.asyncAfter(deadline: .now() + 0.25) {
            // 检查剪贴板是否更新
            if NSPasteboard.general.changeCount > currentChangeCount {
                let text = NSPasteboard.general.string(forType: .string)
                self.logger.info("activeCapture success, length: \(text?.count ?? 0)")
                
                // 获取完内容后，如果需要恢复，则立即恢复
                if restore, let savedItems = savedItems {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.writeObjects(savedItems)
                    self.logger.info("clipboard restored")
                }
                
                completion(text)
            } else {
                // 如果没有变化，尝试读取当前内容作为兜底（可能是用户按得太快，或者模拟失败）
                let text = NSPasteboard.general.string(forType: .string)
                self.logger.info("activeCapture no change, fallback read, length: \(text?.count ?? 0)")
                completion(text)
            }
        }
    }

    private func simulateCopy() {
        let source = CGEventSource(stateID: .combinedSessionState)
        let kVK_ANSI_C: CGKeyCode = 0x08
        let cmdFlag: CGEventFlags = .maskCommand
        
        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: kVK_ANSI_C, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: kVK_ANSI_C, keyDown: false) else { return }
        
        keyDown.flags = cmdFlag
        keyUp.flags = cmdFlag
        
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
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
    private let dragThreshold: CGFloat = 3.0
    private let logger = Logger(subsystem: "ClipLike", category: "Trigger")

    func start() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) { [weak self] _ in
            self?.handleMouseUp()
        }
        globalDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] _ in
            self?.handleMouseDown()
        }
        // 暂时移除快捷键唤起逻辑
        /*
        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleHotkey(event)
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleHotkey(event)
            return event
        }
        */
        if globalMonitor == nil || globalDownMonitor == nil {
            logger.info("global mouse monitor unavailable")
            onInputMonitoringRequired?()
        }
        /*
        if globalKeyMonitor == nil {
            logger.info("global key monitor unavailable")
            onInputMonitoringRequired?()
        }
        */
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
            logger.info("mouseUp trigger without mouseDown")
        }
        
        mouseDownPoint = nil
        pendingWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.onTrigger?(point)
        }
        pendingWorkItem = workItem
        queue.asyncAfter(deadline: .now() + 0.08, execute: workItem)
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
    private static let buttonWidth: CGFloat = 35
    private static let buttonPaddingX: CGFloat = 4
    private static let viewHeight: CGFloat = 35
    private static let buttonCount: CGFloat = 5
    private static let copyButtonIndex: CGFloat = 2
    private static let yOffset: CGFloat = 10
    private let viewSize: NSSize
    private let selectionStore: SelectionStore
    private let selectionService: SelectionService

    init(selectionService: SelectionService) {
        let selectionStore = SelectionStore()
        let selectionServiceRef = selectionService
        let logger = Logger(subsystem: "ClipLike", category: "Overlay")
        let viewSize = NSSize(
            width: (Self.buttonCount * Self.buttonWidth) + (Self.buttonPaddingX * 2),
            height: Self.viewHeight
        )
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
                onLink: { [weak panel] in
                    OverlayController.performOpenLink(selectionService: selectionServiceRef, selectionStore: selectionStore, logger: logger)
                    panel?.orderOut(nil)
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
                    OverlayController.performBob(selectionService: selectionServiceRef, selectionStore: selectionStore, logger: logger)
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
        self.viewSize = viewSize
    }

    func updateSelection(text: String) {
        selectionStore.text = text
    }

    func show(at point: NSPoint, selectionRect: CGRect?) {
        let logger = Logger(subsystem: "ClipLike", category: "Overlay")
        let anchorPoint = point
        let screen = NSScreen.screens.first(where: { $0.frame.contains(anchorPoint) }) ?? NSScreen.main
        let visibleFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let copyCenterX = Self.buttonPaddingX + (Self.copyButtonIndex + 0.5) * Self.buttonWidth
        var origin = NSPoint(x: anchorPoint.x - copyCenterX, y: anchorPoint.y + Self.yOffset)
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
        let text = selectionStore.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            logger.info("performCopy: text empty, attempting active capture")
            // 复制操作不需要恢复剪贴板（本身就是为了写入）
            selectionService.activeCapture(restore: false) { capturedText in
                guard let capturedText = capturedText, !capturedText.isEmpty else {
                    logger.info("activeCapture failed or empty")
                    return
                }
                DispatchQueue.main.async {
                    selectionStore.text = capturedText
                    // activeCapture 已经将内容写入剪贴板（通过 simulateCopy），所以这里其实不需要再次 setString
                    // 但为了保险起见（比如 fallback read 读的是旧的），还是写一次？
                    // 不，如果 activeCapture 成功，说明 Cmd+C 成功，剪贴板里已经是新的了。
                    // 如果 activeCapture 是 fallback read，说明剪贴板没变，那也没必要写。
                    // 唯一例外是：如果 activeCapture 返回了文本，但我们想明确“复制操作成功”的反馈。
                    // 这里我们还是显式写一次，确保一致性。
                    NSPasteboard.general.clearContents()
                    let ok = NSPasteboard.general.setString(capturedText, forType: .string)
                    logger.info("active capture copy ok=\(ok), length=\(capturedText.count)")
                }
            }
            return
        }
        
        DispatchQueue.main.async {
            NSPasteboard.general.clearContents()
            let ok = NSPasteboard.general.setString(text, forType: .string)
            logger.info("copy performed directly from store, ok=\(ok), length=\(text.count)")
        }
    }

    private static func performSearch(selectionService: SelectionService, selectionStore: SelectionStore, logger: Logger) {
        let text = selectionStore.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if text.isEmpty {
            logger.info("performSearch: text empty, attempting active capture")
            // 搜索操作需要恢复剪贴板
            selectionService.activeCapture(restore: true) { capturedText in
                guard let capturedText = capturedText, !capturedText.isEmpty else { return }
                let trimmed = capturedText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                
                let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "https://www.google.com/search?q=\(encoded)") {
                    DispatchQueue.main.async {
                        selectionStore.text = trimmed
                        NSWorkspace.shared.open(url)
                        logger.info("active capture search length=\(trimmed.count)")
                    }
                }
            }
            return
        }
        
        guard !text.isEmpty else { return }
        
        let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://www.google.com/search?q=\(encoded)") {
            DispatchQueue.main.async {
                NSWorkspace.shared.open(url)
                logger.info("search performed directly from store, length=\(text.count)")
            }
        }
    }

    private static func performOpenLink(selectionService: SelectionService, selectionStore: SelectionStore, logger: Logger) {
        let text = selectionStore.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            logger.info("performOpenLink: text empty, attempting active capture")
            // 打开链接需要恢复剪贴板
            selectionService.activeCapture(restore: true) { capturedText in
                guard let capturedText = capturedText, !capturedText.isEmpty else { return }
                let trimmed = capturedText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                
                DispatchQueue.main.async {
                    selectionStore.text = trimmed
                    OverlayController.openLink(text: trimmed, logger: logger)
                }
            }
            return
        }
        
        DispatchQueue.main.async {
            OverlayController.openLink(text: text, logger: logger)
        }
    }

    private static func openLink(text: String, logger: Logger) {
        // 尝试构建有效的 URL
        // 1. 如果是标准的 URL 格式（包含 scheme），直接打开
        // 2. 如果不包含 scheme，尝试添加 https:// 后判断是否为有效域名/IP
        // 3. 如果包含空格或其他非 URL 字符，或者上述尝试失败，则作为搜索词处理
        
        var urlToOpen: URL?
        
        if let url = URL(string: text), url.scheme != nil, url.host != nil {
             urlToOpen = url
        } else if let url = URL(string: "https://" + text), url.host != nil, !text.contains(" ") {
             urlToOpen = url
        }
        
        if let url = urlToOpen {
             NSWorkspace.shared.open(url)
             logger.info("openLink performed as URL: \(url.absoluteString)")
        } else {
             logger.info("openLink fallback to search: \(text)")
             if let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let searchUrl = URL(string: "https://www.google.com/search?q=\(encoded)") {
                  NSWorkspace.shared.open(searchUrl)
             }
        }
    }

    private static func performBob(selectionService: SelectionService, selectionStore: SelectionStore, logger: Logger) {
        let text = selectionStore.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if text.isEmpty {
            logger.info("performBob: text empty, attempting active capture")
            // Bob 翻译操作需要恢复剪贴板
            selectionService.activeCapture(restore: true) { capturedText in
                guard let capturedText = capturedText, !capturedText.isEmpty else {
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "无法获取文本"
                        alert.informativeText = "未能从选区或剪贴板获取到有效文本，请尝试重新选择。"
                        alert.runModal()
                    }
                    return
                }
                let trimmed = capturedText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "文本为空"
                        alert.informativeText = "获取到的文本为空白字符。"
                        alert.runModal()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    selectionStore.text = trimmed
                    OverlayController.callBob(text: trimmed, logger: logger)
                }
            }
            return
        }
        
        DispatchQueue.main.async {
             OverlayController.callBob(text: text, logger: logger)
        }
    }

    private static func callBob(text: String, logger: Logger) {
        // 使用 Codable 构建 JSON，避免手动转义错误
        struct BobBody: Codable {
            let action: String
            let text: String
        }
        struct BobRequest: Codable {
            let path: String
            let body: BobBody
        }
        
        let request = BobRequest(path: "translate", body: BobBody(action: "translateText", text: text))
        
        guard let jsonData = try? JSONEncoder().encode(request),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            logger.error("Failed to encode Bob request")
            return
        }
        
        // 转义 JSON 字符串以用于 AppleScript
        let escapedJson = jsonString.replacingOccurrences(of: "\\", with: "\\\\")
                                    .replacingOccurrences(of: "\"", with: "\\\"")
        
        // 动态查找已安装的 Bob Bundle ID，避免编译不存在的 App 导致 AppleScript 报错
        let bobBundleIDs = ["com.hezongyidev.Bob", "com.hezongyidev.Bob-Setapp", "com.ripperhe.Bob"]
        var targetBundleID: String?
        
        for bundleID in bobBundleIDs {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
                targetBundleID = bundleID
                logger.info("Found Bob: \(bundleID) at \(url.path)")
                break
            }
        }
        
        let scriptSource: String
        if let bundleID = targetBundleID {
            scriptSource = "tell application id \"\(bundleID)\" to request \"\(escapedJson)\""
        } else {
            // 如果没找到已知 Bundle ID，尝试通过名称调用（兜底）
            // 注意：如果系统找不到名为 "Bob" 的应用，这里可能会在编译阶段报错
            scriptSource = "tell application \"Bob\" to request \"\(escapedJson)\""
        }
        
        logger.info("calling Bob with script for: \(targetBundleID ?? "Bob (name)")")
        
        // 使用 Process 调用 osascript，比 NSAppleScript 更容易触发权限弹窗
        // 在后台线程执行，避免阻塞主线程导致 UI 卡死
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            
            let inputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardInput = inputPipe
            process.standardError = errorPipe
            
            do {
                try process.run()
                
                if let data = scriptSource.data(using: .utf8) {
                    inputPipe.fileHandleForWriting.write(data)
                    inputPipe.fileHandleForWriting.closeFile()
                }
                
                process.waitUntilExit()
                
                if process.terminationStatus != 0 {
                    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                    let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                    logger.error("osascript failed: \(errorString)")
                    
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "无法调用 Bob"
                        
                        var helpText = ""
                        if errorString.contains("Not authorized") || errorString.contains("-1743") {
                            helpText = "\n\n这是权限问题。请尝试：\n1. 打开终端 (Terminal)\n2. 输入并运行: tccutil reset AppleEvents\n3. 重启 ClipLike 并再次尝试"
                        }
                        
                        if let bundleID = targetBundleID {
                            alert.informativeText = "调用 Bob (\(bundleID)) 失败。\n请检查 系统设置 > 隐私与安全性 > 自动化 中是否允许 ClipLike 控制 Bob。\(helpText)\n\n错误信息：\(errorString)"
                        } else {
                             alert.informativeText = "未找到 Bob 应用，或调用失败。\n请确保已安装 Bob 并在 系统设置 > 隐私与安全性 > 自动化 中授权。\(helpText)\n\n错误信息：\(errorString)"
                        }
                        alert.runModal()
                    }
                }
            } catch {
                 logger.error("Failed to launch osascript: \(error)")
                 DispatchQueue.main.async {
                     let alert = NSAlert()
                     alert.messageText = "无法启动脚本"
                     alert.informativeText = "无法启动 osascript 进程。\n错误信息：\(error.localizedDescription)"
                     alert.runModal()
                 }
            }
        }
    }

    private static func performRagHubShortcut() {
        // 先进行主动捕获，确保剪贴板中有最新选中的内容
        // 即使 AX 已经获取到了文本，因为 RAG Hub 可能是通过 Cmd+V 粘贴的（如果它不是自己去读剪贴板的话），
        // 所以我们必须把内容写入剪贴板。
        // 而 activeCapture 本身就会模拟 Cmd+C 并写入剪贴板。
        // 这里不需要 restore，因为我们就是要让剪贴板变成最新的内容供 RAG Hub 粘贴。
        
        // 获取 SelectionService 实例比较麻烦，因为这里是静态方法。
        // 我们通过 AppDelegate 获取
        guard let appDelegate = AppDelegate.shared,
              let selectionService = appDelegate.selectionService else {
            print("SelectionService not found")
            return
        }
        
        selectionService.activeCapture(restore: false) { capturedText in
             // 无论是否捕获成功（可能是空文本），都尝试唤起 RAG Hub
             // 因为用户可能就是想打开它
             DispatchQueue.main.async {
                 activateRagHubAndPaste()
             }
        }
    }
    
    private static func activateRagHubAndPaste() {
        let bundleID = "com.localraghub.desktop"
        let workspace = NSWorkspace.shared
        
        // 1. 检查应用是否正在运行
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
        let isRunning = !runningApps.isEmpty
        
        if isRunning {
            // 如果已运行，激活它
            if let app = runningApps.first {
                app.activate(options: .activateIgnoringOtherApps)
            }
        } else {
            // 如果未运行，启动它
            if let url = workspace.urlForApplication(withBundleIdentifier: bundleID) {
                let config = NSWorkspace.OpenConfiguration()
                config.activates = true
                workspace.openApplication(at: url, configuration: config) { _, error in
                    if let error = error {
                        print("Failed to launch LocalRAG Hub: \(error)")
                    }
                }
            } else {
                 print("LocalRAG Hub bundle ID not found, attempting to find by name...")
            }
        }
        
        // 2. 无论启动与否，延时后发送快捷键 Cmd+K 和 Cmd+V
        // 如果是刚启动，可能需要更长的等待时间。
        let delay = isRunning ? 0.15 : 1.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard let source = CGEventSource(stateID: .combinedSessionState) else { return }
            
            // 发送 Cmd+K (唤起窗口)
            let kVK_ANSI_K: CGKeyCode = 40
            func sendKey(keyCode: CGKeyCode, flags: CGEventFlags) {
                guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
                      let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else { return }
                keyDown.flags = flags
                keyUp.flags = flags
                keyDown.post(tap: .cghidEventTap)
                keyUp.post(tap: .cghidEventTap)
            }
            
            sendKey(keyCode: kVK_ANSI_K, flags: .maskCommand)
            
            // 发送 Cmd+V (粘贴文本)
            // 延时 0.8s，确保窗口完全唤起并聚焦
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                let kVK_ANSI_V: CGKeyCode = 0x09
                sendKey(keyCode: kVK_ANSI_V, flags: .maskCommand)
            }
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
