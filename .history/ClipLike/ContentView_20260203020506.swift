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

#Preview {
    OverlayView(onCopy: {}, onSearch: {}, onBob: {})
}
