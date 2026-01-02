//
//  SettingsViewModel.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData
import UserNotifications

/// 設定画面のViewModel
@MainActor
final class SettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var notificationEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(notificationEnabled, forKey: "notificationEnabled")
            if notificationEnabled {
                requestNotificationPermission()
            }
        }
    }
    
    @Published var notificationTime: Date = Date() {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
        }
    }
    
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Properties
    
    /// アプリバージョン
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// ビルド番号
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - Init
    
    init() {
        loadSettings()
        checkNotificationPermission()
    }
    
    // MARK: - Private Methods
    
    private func loadSettings() {
        notificationEnabled = UserDefaults.standard.bool(forKey: "notificationEnabled")
        
        if let savedTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
            notificationTime = savedTime
        } else {
            // デフォルトの通知時刻（9:00）
            var components = DateComponents()
            components.hour = AppConstants.defaultNotificationHour
            components.minute = AppConstants.defaultNotificationMinute
            notificationTime = Calendar.current.date(from: components) ?? Date()
        }
    }
    
    // MARK: - Public Methods
    
    /// 通知権限を確認
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionStatus = settings.authorizationStatus
            }
        }
    }
    
    /// 通知権限をリクエスト
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.checkNotificationPermission()
                if !granted {
                    self.notificationEnabled = false
                }
            }
        }
    }
}
