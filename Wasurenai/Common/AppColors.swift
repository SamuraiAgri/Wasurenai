//
//  AppColors.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// アプリ全体で使用するカラーパレット
/// Human Interface Guidelinesに準拠した統一的なカラー管理
/// ダークモード対応
struct AppColors {
    
    // MARK: - Primary Colors（ライト/ダーク共通）
    
    /// メインのアクセントカラー（ティール系）
    static let primary = Color(hex: "00A896")
    
    /// セカンダリカラー（暖かみのあるコーラル）
    static let secondary = Color(hex: "F77F00")
    
    /// サクセスカラー（完了・成功）
    static let success = Color(hex: "06D6A0")
    
    /// 警告カラー（期限が近い）
    static let warning = Color(hex: "FFD166")
    
    /// 危険カラー（期限切れ）
    static let danger = Color(hex: "EF476F")
    
    // MARK: - Background Colors（ダークモード対応）
    
    /// メイン背景色
    static let background = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1) // #1C1C1E
            : UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1) // #F8F9FA
    })
    
    /// カード背景色
    static let cardBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1) // #2C2C2E
            : UIColor.white
    })
    
    /// セカンダリ背景色
    static let secondaryBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.23, green: 0.23, blue: 0.24, alpha: 1) // #3A3A3C
            : UIColor(red: 0.91, green: 0.93, blue: 0.94, alpha: 1) // #E9ECEF
    })
    
    // MARK: - Text Colors（ダークモード対応）
    
    /// プライマリテキスト
    static let textPrimary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor(red: 0.13, green: 0.15, blue: 0.16, alpha: 1) // #212529
    })
    
    /// セカンダリテキスト
    static let textSecondary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.67, green: 0.67, blue: 0.69, alpha: 1) // #ABABAF
            : UIColor(red: 0.42, green: 0.46, blue: 0.49, alpha: 1) // #6C757D
    })
    
    /// プレースホルダーテキスト
    static let textPlaceholder = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.46, green: 0.46, blue: 0.48, alpha: 1) // #75757A
            : UIColor(red: 0.68, green: 0.71, blue: 0.74, alpha: 1) // #ADB5BD
    })
    
    // MARK: - Category Colors
    
    /// カテゴリ用のカラーパレット
    static let categoryColors: [String] = [
        "00A896", // ティール
        "F77F00", // オレンジ
        "7B2CBF", // パープル
        "3A86FF", // ブルー
        "06D6A0", // グリーン
        "EF476F", // ピンク
        "FFD166", // イエロー
        "118AB2", // ダークティール
    ]
    
    // MARK: - Gradient
    
    /// プライマリグラデーション
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "00A896"), Color(hex: "02C39A")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 背景グラデーション
    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Color Extension

extension Color {
    /// HEXカラーコードからColorを生成
    /// - Parameter hex: 6桁のHEXカラーコード（#なし）
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
