//
//  SettingsView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// 設定画面
struct SettingsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingHistory = false
    
    var body: some View {
        NavigationStack {
            Form {
                // データ管理セクション
                dataSection
                
                // カテゴリ管理セクション
                categorySection
                
                // 通知設定セクション
                notificationSection
                
                // アプリ情報セクション
                aboutSection
            }
            .navigationTitle(AppStrings.settingsTitle)
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingHistory) {
                HistoryView()
            }
        }
    }
    
    // MARK: - Sections
    
    private var dataSection: some View {
        Section {
            // 完了履歴
            Button {
                showingHistory = true
            } label: {
                HStack {
                    settingsIcon("clock.arrow.circlepath", color: AppColors.success)
                    Text("完了履歴")
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Image(systemName: AppIcons.chevronRight)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textPlaceholder)
                }
            }
        }
    }
    
    private var categorySection: some View {
        Section {
            NavigationLink {
                CategoryListView()
                    .environment(\.managedObjectContext, viewContext)
            } label: {
                HStack {
                    settingsIcon(AppIcons.tabItemsOutline, color: AppColors.secondary)
                    Text(AppStrings.settingsCategoryManagement)
                }
            }
        }
    }
    
    private var notificationSection: some View {
        Section(header: Text(AppStrings.settingsNotification)) {
            Toggle(isOn: $viewModel.notificationEnabled) {
                HStack {
                    settingsIcon(AppIcons.bell, color: AppColors.primary)
                    Text(AppStrings.settingsNotificationEnable)
                }
            }
            .tint(AppColors.primary)
            
            if viewModel.notificationEnabled {
                DatePicker(
                    selection: $viewModel.notificationTime,
                    displayedComponents: .hourAndMinute
                ) {
                    HStack {
                        settingsIcon(AppIcons.upcoming, color: AppColors.warning)
                        Text(AppStrings.settingsNotificationTime)
                    }
                }
                .tint(AppColors.primary)
            }
            
            if viewModel.notificationPermissionStatus == .denied {
                HStack {
                    Image(systemName: AppIcons.warning)
                        .foregroundColor(AppColors.danger)
                    Text("通知の権限が拒否されています。設定アプリから有効にしてください。")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.danger)
                }
            }
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text(AppStrings.settingsAbout)) {
            HStack {
                settingsIcon("info.circle.fill", color: AppColors.textSecondary)
                Text(AppStrings.settingsVersion)
                Spacer()
                Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func settingsIcon(_ name: String, color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(color)
            .frame(width: 28, height: 28)
            .background(color.opacity(0.15))
            .cornerRadius(6)
    }
}

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
