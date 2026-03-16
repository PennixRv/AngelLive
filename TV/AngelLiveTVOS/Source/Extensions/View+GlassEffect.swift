//
//  View+GlassEffect.swift
//  AngelLive
//
//  Created by some developer on 2024/9/15.
//

import SwiftUI

extension View {
    @ViewBuilder
    func adaptiveGlassEffect() -> some View {
        // "glassEffect" is only available in newer SwiftUI SDKs. Keep CI compatible with
        // GitHub Actions' stable Xcode by using material as a safe fallback.
        self.background(.ultraThinMaterial)
    }

    @ViewBuilder
    func adaptiveGlassEffectCapsule() -> some View {
        self.background(
            .ultraThinMaterial,
            in: Capsule()
        )
    }

    @ViewBuilder
    func adaptiveGlassEffectRoundedRect(cornerRadius: CGFloat = 16) -> some View {
        self.background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: cornerRadius)
        )
    }
}
