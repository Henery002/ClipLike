//
//  ContentView.swift
//  ClipLike
//
//  Created by henery on 2026/2/2.
//

import SwiftUI

struct OverlayView: View {
    let onCopy: () -> Void
    let onSearch: () -> Void
    let onBob: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ActionButton(icon: "doc.on.doc", action: onCopy)
            Divider().frame(height: 16).padding(.horizontal, 4)
            ActionButton(icon: "magnifyingglass", action: onSearch)
            Divider().frame(height: 16).padding(.horizontal, 4)
            ActionButton(icon: "translate", action: onBob)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        )
    }
}

struct ActionButton: View {
    let icon: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary.opacity(0.8))
                .frame(width: 32, height: 32)
                .background(isHovered ? Color.primary.opacity(0.08) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Image(systemName: "rectangle.stack.person.crop")
                    Text("通用")
                }
            ActionsSettingsView()
                .tabItem {
                    Image(systemName: "puzzlepiece")
                    Text("操作")
                }
            AboutSettingsView()
                .tabItem {
                    Image(systemName: "app")
                    Text("关于")
                }
        }
        .frame(minWidth: 640, idealWidth: 700, maxWidth: 900,
               minHeight: 420, idealHeight: 480, maxHeight: 700)
    }
}

struct GeneralSettingsView: View {
    @State private var appRules = false
    @State private var siteRules = false
    @State private var hotkeyRecording = false
    @EnvironmentObject private var settings: SettingsStore

    private let colorOptions = ["自动显示", "浅色", "深色"]
    private let positionOptions = ["文本上方", "文本下方", "鼠标附近"]

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 16) {
                    SettingsSection(title: "App 设置") {
                        VStack(spacing: 10) {
                            SettingsToggleRow(
                                icon: "bolt.horizontal.circle",
                                title: "登录时启动",
                                subtitle: "开机后自动启动 ClipLike。",
                                isOn: $settings.launchAtLogin
                            )
                            SettingsToggleRow(
                                icon: "menubar.rectangle",
                                title: "在菜单栏中显示",
                                subtitle: "保留菜单栏入口以便快速访问。",
                                isOn: $settings.showMenuBar
                            )
                        }
                    }

                    SettingsSection(title: "激活") {
                        VStack(spacing: 12) {
                            SettingsToggleRow(
                                icon: "cursorarrow.click",
                                title: "自动出现",
                                subtitle: "当您使用鼠标指针选择文本或点击并按住文本时，ClipLike 会自动出现。",
                                isOn: $settings.autoShow
                            )
                            SettingsInlineActionRow(
                                icon: "line.3.horizontal.decrease.circle",
                                title: "规则",
                                subtitle: "限制 ClipLike 自动出现的位置。",
                                actions: [
                                    SettingsInlineButton(title: "App…", isOn: $appRules),
                                    SettingsInlineButton(title: "网站…", isOn: $siteRules)
                                ]
                            )
                            SettingsInlineActionRow(
                                icon: "keyboard",
                                title: "键盘快捷键",
                                subtitle: "使用键盘快捷键手动触发 ClipLike。",
                                actions: [
                                    SettingsInlineButton(title: hotkeyRecording ? "正在录制…" : "录制快捷键", isOn: $hotkeyRecording, isPrimary: true)
                                ]
                            )
                        }
                    }

                    SettingsSection(title: "外观") {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 12) {
                                SettingsSliderRow(
                                    title: "大小",
                                    minLabel: "小",
                                    maxLabel: "大",
                                value: $settings.overlaySize
                                )
                            SettingsPickerRow(title: "颜色", selection: $settings.colorMode, options: colorOptions)
                            SettingsPickerRow(title: "位置", selection: $settings.positionMode, options: positionOptions)
                            }
                            Spacer()
                            SettingsPreviewCard()
                        }
                        .padding(.top, 2)
                    }
                }
                .frame(maxWidth: geo.size.width * 0.85, alignment: .leading)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
                .frame(maxWidth: geo.size.width * 0.85, alignment: .leading)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct ActionsSettingsView: View {
    @State private var actions: [ActionConfig] = [
        ActionConfig(title: "打开链接", icon: "link", isOn: true, showsGear: true),
        ActionConfig(title: "搜索", icon: "magnifyingglass", isOn: true, showsGear: true),
        ActionConfig(title: "剪切", icon: "scissors", isOn: false, showsGear: true),
        ActionConfig(title: "拷贝", icon: "doc.on.doc", isOn: true, showsGear: false),
        ActionConfig(title: "Bob", icon: "character.bubble", isOn: true, showsGear: true),
        ActionConfig(title: "LocalRAG Hub", icon: "bolt.horizontal.circle", isOn: false, showsGear: true)
    ]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 16) {
                SettingsSection(title: "操作项") {
                    VStack(spacing: 0) {
                        ForEach(actions.indices, id: \.self) { index in
                            SettingsActionRow(
                                icon: actions[index].icon,
                                title: actions[index].title,
                                isOn: $actions[index].isOn,
                                showsGear: actions[index].showsGear
                            )
                            if index != actions.indices.last {
                                Divider().padding(.leading, 44)
                            }
                        }
                    }
                }
                HStack {
                    Button("获取扩展") {}
                        .buttonStyle(.bordered)
                    Spacer()
                }
                .padding(.horizontal, 8)
                Spacer()
            }
            .frame(maxWidth: geo.size.width * 0.85, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct AboutSettingsView: View {
    private let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "ClipLike"
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    private let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text(appName)
                        .font(.system(size: 20, weight: .semibold))
                    Text("版本 \(version) (\(build))")
                        .foregroundStyle(.secondary)
                }
                SettingsSection(title: "软件信息") {
                    VStack(spacing: 8) {
                        SettingsInfoRow(title: "应用名称", value: appName)
                        SettingsInfoRow(title: "版本号", value: version)
                        SettingsInfoRow(title: "构建号", value: build)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: geo.size.width * 0.85)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            VStack {
                content
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
            )
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                Toggle(isOn: $isOn) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                }
                .toggleStyle(.switch)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct SettingsInlineActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let actions: [SettingsInlineButton]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 8) {
                ForEach(actions) { action in
                    action
                }
            }
        }
    }
}

struct SettingsInlineButton: View, Identifiable {
    let id = UUID()
    let title: String
    @Binding var isOn: Bool
    var isPrimary: Bool = false

    var body: some View {
        Button(title) {
            isOn.toggle()
        }
        .buttonStyle(.bordered)
        .tint(isPrimary ? .accentColor : .clear)
    }
}

struct SettingsSliderRow: View {
    let title: String
    let minLabel: String
    let maxLabel: String
    @Binding var value: Double

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .frame(width: 44, alignment: .leading)
            Text(minLabel)
                .foregroundStyle(.secondary)
            Slider(value: $value)
            Text(maxLabel)
                .foregroundStyle(.secondary)
        }
    }
}

struct SettingsPickerRow: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .frame(width: 44, alignment: .leading)
            Picker("", selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            Spacer()
        }
    }
}

struct SettingsPreviewCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor))
            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    SettingsPreviewButton(icon: "magnifyingglass", isActive: true)
                    SettingsPreviewButton(icon: "doc.on.doc")
                    SettingsPreviewButton(icon: "character.bubble")
                }
                Text("示例")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
            }
        }
        .frame(width: 240, height: 140)
    }
}

struct SettingsPreviewButton: View {
    let icon: String
    var isActive: Bool = false

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(isActive ? Color.white : Color.primary.opacity(0.7))
            .frame(width: 36, height: 30)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isActive ? Color.accentColor : Color.clear)
            )
    }
}

struct SettingsActionRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let showsGear: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 22)
                .foregroundStyle(.secondary)
            Toggle(isOn: $isOn) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .toggleStyle(.checkbox)
            Spacer()
            if showsGear {
                Button(action: {}) {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.bordered)
            }
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
    }
}

struct SettingsInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .font(.system(size: 13))
    }
}

struct ActionConfig: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    var isOn: Bool
    var showsGear: Bool
}

#Preview {
    OverlayView(onCopy: {}, onSearch: {}, onBob: {});
    SettingsView();
}
