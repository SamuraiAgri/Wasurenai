// AppIconGenerator.swift
// このファイルをPlaygroundで実行するか、macOSアプリとして実行してアイコンを生成できます
// 生成後は削除してください

import SwiftUI

struct AppIconView: View {
    let size: CGFloat
    let isDark: Bool
    
    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                gradient: Gradient(colors: isDark ? [
                    Color(red: 0.1, green: 0.15, blue: 0.2),
                    Color(red: 0.15, green: 0.2, blue: 0.25)
                ] : [
                    Color(red: 0.2, green: 0.7, blue: 0.7),   // ティール
                    Color(red: 0.3, green: 0.8, blue: 0.75)   // ライトティール
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // カレンダーアイコン
            VStack(spacing: 0) {
                // カレンダーヘッダー
                RoundedRectangle(cornerRadius: size * 0.03)
                    .fill(isDark ? Color(red: 0.2, green: 0.5, blue: 0.5) : Color.white.opacity(0.9))
                    .frame(width: size * 0.55, height: size * 0.12)
                
                // カレンダー本体
                RoundedRectangle(cornerRadius: size * 0.05)
                    .fill(isDark ? Color(red: 0.15, green: 0.2, blue: 0.25) : Color.white)
                    .frame(width: size * 0.55, height: size * 0.45)
                    .overlay(
                        // チェックマーク
                        Image(systemName: "checkmark")
                            .font(.system(size: size * 0.2, weight: .bold))
                            .foregroundColor(isDark ? Color(red: 0.3, green: 0.8, blue: 0.7) : Color(red: 0.2, green: 0.7, blue: 0.7))
                    )
            }
            .offset(y: -size * 0.02)
            
            // カラフルなドット（リマインダーアイテムを表現）
            HStack(spacing: size * 0.04) {
                Circle()
                    .fill(Color(red: 1.0, green: 0.4, blue: 0.4))  // 赤
                    .frame(width: size * 0.08, height: size * 0.08)
                Circle()
                    .fill(Color(red: 1.0, green: 0.7, blue: 0.3))  // オレンジ
                    .frame(width: size * 0.08, height: size * 0.08)
                Circle()
                    .fill(Color(red: 0.4, green: 0.8, blue: 0.4))  // グリーン
                    .frame(width: size * 0.08, height: size * 0.08)
            }
            .offset(y: size * 0.35)
        }
        .frame(width: size, height: size)
    }
}

#Preview("App Icon Light") {
    AppIconView(size: 1024, isDark: false)
}

#Preview("App Icon Dark") {
    AppIconView(size: 1024, isDark: true)
}
