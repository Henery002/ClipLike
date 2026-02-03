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
        HStack(spacing: 10) {
            Button("复制", action: onCopy)
            Button("搜索", action: onSearch)
            Button("Bob", action: onBob)
        }
        .font(.system(size: 12, weight: .medium))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    OverlayView(onCopy: {}, onSearch: {}, onBob: {})
}
