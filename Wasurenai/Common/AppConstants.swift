//
//  AppConstants.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import SwiftUI

/// アプリ全体で使用する定数
struct AppConstants {
    
    // MARK: - Animation
    
    /// 標準アニメーション時間
    static let animationDuration: Double = 0.3
    
    /// スプリングアニメーション
    static let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.7)
    
    // MARK: - Layout
    
    /// 標準パディング
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    
    /// 標準コーナーラディウス
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    
    /// カードシャドウ
    static let shadowRadius: CGFloat = 8
    static let shadowOpacity: Double = 0.08
    
    // MARK: - Default Values
    
    /// デフォルトの交換サイクル（日）
    static let defaultCycleDays: Int16 = 30
    
    /// デフォルトの通知日数（何日前に通知するか）
    static let defaultNotifyBefore: Int16 = 1
    
    /// 通知時刻のデフォルト（時）
    static let defaultNotificationHour: Int = 9
    
    /// 通知時刻のデフォルト（分）
    static let defaultNotificationMinute: Int = 0
    
    // MARK: - Cycle Presets
    
    /// よく使うサイクルのプリセット
    static let cyclePresets: [Int] = [7, 14, 30, 60, 90, 180, 365]
    
    /// サイクルの最小値（日）
    static let minCycleDays: Int = 1
    
    /// サイクルの最大値（日）
    static let maxCycleDays: Int = 365
    
    // MARK: - Due Date Thresholds
    
    /// 期限が近いと判定する日数
    static let upcomingThresholdDays: Int = 3
    
    /// 今週と判定する日数
    static let thisWeekDays: Int = 7
}
