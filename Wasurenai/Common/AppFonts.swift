//
//  AppFonts.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// アプリ全体で使用するフォントスタイル
/// Human Interface Guidelinesに準拠した統一的なタイポグラフィ
struct AppFonts {
    
    // MARK: - Title Fonts
    
    /// 大見出し（画面タイトルなど）
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    
    /// 中見出し（セクションタイトルなど）
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    
    /// 小見出し
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    
    /// サブタイトル
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // MARK: - Body Fonts
    
    /// 見出し
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    
    /// 本文（標準）
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    
    /// 本文（強調）
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .rounded)
    
    /// サブ本文
    static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    
    /// サブ本文（強調）
    static let subheadlineBold = Font.system(size: 15, weight: .semibold, design: .rounded)
    
    // MARK: - Caption Fonts
    
    /// キャプション（注釈など）
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    
    /// キャプション（強調）
    static let captionBold = Font.system(size: 12, weight: .medium, design: .rounded)
    
    // MARK: - Special Fonts
    
    /// 数字表示用（日数カウントなど）
    static let number = Font.system(size: 48, weight: .bold, design: .rounded)
    
    /// 小さい数字表示用
    static let numberSmall = Font.system(size: 24, weight: .bold, design: .rounded)
    
    /// バッジ用
    static let badge = Font.system(size: 11, weight: .semibold, design: .rounded)
}
