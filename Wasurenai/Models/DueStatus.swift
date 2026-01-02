//
//  DueStatus.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// 期日のステータスを表す列挙型
enum DueStatus: Equatable {
    case overdue(days: Int)    // 期限切れ（何日超過か）
    case today                  // 今日が期限
    case tomorrow               // 明日が期限
    case upcoming(days: Int)    // もうすぐ（3日以内）
    case later(days: Int)       // まだ先
    
    /// 日付からステータスを判定
    static func from(date: Date?) -> DueStatus {
        guard let date = date else { return .later(days: 0) }
        
        let days = date.daysFromToday
        
        if days < 0 {
            return .overdue(days: abs(days))
        } else if days == 0 {
            return .today
        } else if days == 1 {
            return .tomorrow
        } else if days <= AppConstants.upcomingThresholdDays {
            return .upcoming(days: days)
        } else {
            return .later(days: days)
        }
    }
    
    /// ステータスに対応するカラー
    var color: Color {
        switch self {
        case .overdue:
            return AppColors.danger
        case .today:
            return AppColors.warning
        case .tomorrow:
            return AppColors.secondary
        case .upcoming:
            return AppColors.primary
        case .later:
            return AppColors.textSecondary
        }
    }
    
    /// ステータスに対応するアイコン
    var iconName: String {
        switch self {
        case .overdue:
            return AppIcons.expired
        case .today:
            return AppIcons.warning
        case .tomorrow, .upcoming:
            return AppIcons.upcoming
        case .later:
            return AppIcons.calendar
        }
    }
    
    /// 表示用テキスト
    var displayText: String {
        switch self {
        case .overdue(let days):
            return String(format: AppStrings.homeDueOverdueFormat, days)
        case .today:
            return AppStrings.homeDueToday
        case .tomorrow:
            return AppStrings.homeDueTomorrow
        case .upcoming(let days), .later(let days):
            return String(format: AppStrings.homeDueDaysFormat, days)
        }
    }
    
    /// 優先度（ソート用、小さいほど優先度が高い）
    var priority: Int {
        switch self {
        case .overdue:
            return 0
        case .today:
            return 1
        case .tomorrow:
            return 2
        case .upcoming:
            return 3
        case .later:
            return 4
        }
    }
}
