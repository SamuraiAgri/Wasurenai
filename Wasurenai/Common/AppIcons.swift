//
//  AppIcons.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// アプリ全体で使用するSF Symbolsアイコン
/// 統一的なアイコン管理
struct AppIcons {
    
    // MARK: - Tab Icons
    
    static let tabHome = "house.fill"
    static let tabHomeOutline = "house"
    static let tabCalendar = "calendar"
    static let tabCalendarOutline = "calendar"
    static let tabItems = "list.bullet.rectangle.fill"
    static let tabItemsOutline = "list.bullet.rectangle"
    static let tabSettings = "gearshape.fill"
    static let tabSettingsOutline = "gearshape"
    
    // MARK: - Action Icons
    
    static let add = "plus"
    static let addCircle = "plus.circle.fill"
    static let check = "checkmark"
    static let checkCircle = "checkmark.circle.fill"
    static let edit = "pencil"
    static let delete = "trash"
    static let refresh = "arrow.clockwise"
    static let close = "xmark"
    static let chevronRight = "chevron.right"
    static let calendar = "calendar"
    static let bell = "bell.fill"
    static let bellSlash = "bell.slash"
    
    // MARK: - Status Icons
    
    static let warning = "exclamationmark.triangle.fill"
    static let expired = "clock.badge.exclamationmark"
    static let upcoming = "clock.fill"
    static let completed = "checkmark.seal.fill"
    
    // MARK: - Category Icons
    
    /// カテゴリ用のアイコンリスト
    static let categoryIcons: [String] = [
        "drop.fill",           // 洗剤・液体
        "sparkles",            // 掃除用品
        "leaf.fill",           // 消臭・芳香剤
        "pills.fill",          // 薬・サプリ
        "lightbulb.fill",      // 電球・電池
        "line.3.horizontal.decrease.circle.fill", // フィルター
        "ant.fill",            // 防虫剤
        "bubbles.and.sparkles.fill", // バス用品
        "washer.fill",         // 洗濯用品
        "refrigerator.fill",   // 冷蔵庫関連
        "fan.fill",            // 空調関連
        "cross.case.fill",     // 医療・救急
        "pawprint.fill",       // ペット用品
        "carrot.fill",         // 食品
        "shippingbox.fill",    // その他
        "star.fill",           // お気に入り
    ]
    
    // MARK: - Default Item Icons
    
    /// アイテム用のアイコンリスト
    static let itemIcons: [String] = [
        "drop.fill",
        "sparkles",
        "bubbles.and.sparkles.fill",
        "flame.fill",
        "leaf.fill",
        "wind",
        "humidity.fill",
        "aqi.medium",
        "pills.fill",
        "cross.case.fill",
        "lightbulb.fill",
        "battery.100.bolt",
        "line.3.horizontal.decrease.circle.fill",
        "ant.fill",
        "washer.fill",
        "refrigerator.fill",
        "fan.fill",
        "pawprint.fill",
        "carrot.fill",
        "cup.and.saucer.fill",
        "bag.fill",
        "shippingbox.fill",
        "wrench.and.screwdriver.fill",
        "hammer.fill",
    ]
}
