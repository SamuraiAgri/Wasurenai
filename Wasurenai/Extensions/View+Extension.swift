//
//  View+Extension.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

extension View {
    
    /// カードスタイルを適用
    func cardStyle() -> some View {
        self
            .background(AppColors.cardBackground)
            .cornerRadius(AppConstants.cornerRadiusMedium)
            .shadow(
                color: Color.black.opacity(AppConstants.shadowOpacity),
                radius: AppConstants.shadowRadius,
                x: 0,
                y: 2
            )
    }
    
    /// 押下時のスケールエフェクト
    func pressableStyle() -> some View {
        self.buttonStyle(PressableButtonStyle())
    }
    
    /// 条件付きモディファイア
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

/// 押下時にスケールするボタンスタイル
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
