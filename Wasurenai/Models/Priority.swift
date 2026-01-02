//
//  Priority.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// アイテムの優先度
enum Priority: Int16, CaseIterable, Identifiable {
    case low = 0
    case medium = 1
    case high = 2
    
    var id: Int16 { rawValue }
    
    /// 表示名
    var displayName: String {
        switch self {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        }
    }
    
    /// アイコン名
    var iconName: String {
        switch self {
        case .low: return "arrow.down.circle.fill"
        case .medium: return "minus.circle.fill"
        case .high: return "arrow.up.circle.fill"
        }
    }
    
    /// 色
    var color: Color {
        switch self {
        case .low: return AppColors.success
        case .medium: return AppColors.warning
        case .high: return AppColors.danger
        }
    }
    
    /// ソート用の優先度（高い方が先）
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
    
    /// Int16から変換
    static func from(_ value: Int16) -> Priority {
        Priority(rawValue: value) ?? .medium
    }
}
