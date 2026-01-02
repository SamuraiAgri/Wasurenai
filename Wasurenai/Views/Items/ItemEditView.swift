//
//  ItemEditView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// アイテム編集・追加画面
struct ItemEditView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ItemEditViewModel
    @State private var showingDeleteAlert = false
    @State private var showingIconPicker = false
    
    /// 新規作成用
    init() {
        _viewModel = StateObject(wrappedValue: ItemEditViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    /// 編集用
    init(item: ReminderItem) {
        _viewModel = StateObject(wrappedValue: ItemEditViewModel(
            context: PersistenceController.shared.container.viewContext,
            item: item
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 基本情報セクション
                basicInfoSection
                
                // サイクル設定セクション
                cycleSection
                
                // 通知設定セクション
                notificationSection
                
                // メモセクション
                memoSection
                
                // 削除ボタン（編集時のみ）
                if viewModel.isEditing {
                    deleteSection
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
            .alert(AppStrings.alertDeleteTitle, isPresented: $showingDeleteAlert) {
                Button(AppStrings.actionCancel, role: .cancel) { }
                Button(AppStrings.actionDelete, role: .destructive) {
                    viewModel.delete()
                    dismiss()
                }
            } message: {
                Text(AppStrings.alertDeleteItemMessage)
            }
            .sheet(isPresented: $showingIconPicker) {
                iconPickerSheet
            }
        }
    }
    
    // MARK: - Sections
    
    private var basicInfoSection: some View {
        Section {
            // アイテム名
            HStack {
                Text(AppStrings.itemDetailName)
                    .foregroundColor(AppColors.textSecondary)
                TextField(AppStrings.itemDetailNamePlaceholder, text: $viewModel.name)
                    .multilineTextAlignment(.trailing)
            }
            
            // アイコン選択
            Button {
                showingIconPicker = true
            } label: {
                HStack {
                    Text(AppStrings.itemDetailIcon)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Image(systemName: viewModel.selectedIconName)
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primary)
                    Image(systemName: AppIcons.chevronRight)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textPlaceholder)
                }
            }
            
            // 部屋選択
            Picker("場所", selection: $viewModel.selectedRoom) {
                Text("未設定")
                    .tag(nil as Room?)
                ForEach(viewModel.rooms, id: \.objectID) { room in
                    HStack {
                        Image(systemName: room.iconName ?? "house.fill")
                        Text(room.name ?? "")
                    }
                    .tag(room as Room?)
                }
            }
            .tint(AppColors.primary)
            
            // 優先度選択
            Picker("優先度", selection: $viewModel.priority) {
                ForEach(Priority.allCases) { priority in
                    HStack {
                        Image(systemName: priority.iconName)
                            .foregroundColor(priority.color)
                        Text(priority.displayName)
                    }
                    .tag(priority)
                }
            }
            .tint(AppColors.primary)
        }
    }
    
    private var cycleSection: some View {
        Section {
            // サイクル日数
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("交換サイクル")
                        .foregroundColor(AppColors.textPrimary)
                    Text("完了時に自動で次回期日を更新")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Picker("", selection: $viewModel.cycleDays) {
                    ForEach(AppConstants.cyclePresets, id: \.self) { days in
                        Text("\(days)日").tag(days)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColors.primary)
                .onChange(of: viewModel.cycleDays) { _, _ in
                    viewModel.updateDueDateFromCycle()
                }
            }
            
            // 次回期日
            DatePicker(
                selection: $viewModel.dueDate,
                displayedComponents: .date
            ) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("次回期日")
                        .foregroundColor(AppColors.textPrimary)
                    if !viewModel.isEditing {
                        Text("今日から\(viewModel.cycleDays)日後")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .tint(AppColors.primary)
        } header: {
            Text("スケジュール")
        } footer: {
            Text("「完了」ボタンを押すと、交換サイクルに基づいて次回期日が自動更新されます。")
                .font(AppFonts.caption)
        }
    }
    
    private var notificationSection: some View {
        Section(header: Text(AppStrings.itemDetailNotify)) {
            Toggle(isOn: $viewModel.notifyEnabled) {
                HStack {
                    Image(systemName: viewModel.notifyEnabled ? AppIcons.bell : AppIcons.bellSlash)
                        .foregroundColor(viewModel.notifyEnabled ? AppColors.primary : AppColors.textSecondary)
                    Text(AppStrings.settingsNotificationEnable)
                }
            }
            .tint(AppColors.primary)
            
            if viewModel.notifyEnabled {
                HStack {
                    Text(AppStrings.itemDetailNotifyBefore)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Picker("", selection: $viewModel.notifyBefore) {
                        ForEach([0, 1, 2, 3, 7], id: \.self) { days in
                            if days == 0 {
                                Text("当日").tag(days)
                            } else {
                                Text("\(days)日前").tag(days)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppColors.primary)
                }
            }
        }
    }
    
    private var memoSection: some View {
        Section(header: Text(AppStrings.itemDetailMemo)) {
            TextEditor(text: $viewModel.memo)
                .frame(minHeight: 80)
                .overlay(alignment: .topLeading) {
                    if viewModel.memo.isEmpty {
                        Text(AppStrings.itemDetailMemoPlaceholder)
                            .foregroundColor(AppColors.textPlaceholder)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
    
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                HStack {
                    Spacer()
                    Label(AppStrings.actionDelete, systemImage: AppIcons.delete)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Toolbar Buttons
    
    private var cancelButton: some View {
        Button(AppStrings.actionCancel) {
            dismiss()
        }
        .foregroundColor(AppColors.textSecondary)
    }
    
    private var saveButton: some View {
        Button(AppStrings.actionSave) {
            viewModel.save()
            dismiss()
        }
        .font(AppFonts.bodyBold)
        .foregroundColor(viewModel.canSave ? AppColors.primary : AppColors.textPlaceholder)
        .disabled(!viewModel.canSave)
    }
    
    // MARK: - Icon Picker Sheet
    
    private var iconPickerSheet: some View {
        NavigationStack {
            ScrollView {
                IconPickerView(
                    selectedIconName: $viewModel.selectedIconName,
                    icons: AppIcons.itemIcons,
                    accentColor: AppColors.primary
                )
                .padding()
            }
            .navigationTitle(AppStrings.itemDetailIcon)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.actionDone) {
                        showingIconPicker = false
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ItemEditView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
