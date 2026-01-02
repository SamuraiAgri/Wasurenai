//
//  PresetSelectionView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI
import CoreData

/// プリセットアイテム選択画面
struct PresetSelectionView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedPresets: Set<PresetItem> = []
    @State private var showingConfirmation = false
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppConstants.paddingLarge) {
                        // 説明テキスト
                        headerSection
                        
                        // カテゴリごとのプリセット
                        ForEach(PresetItem.presets) { category in
                            presetCategorySection(category)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.vertical, AppConstants.paddingMedium)
                }
                
                // 追加ボタン
                if !selectedPresets.isEmpty {
                    addButtonOverlay
                }
            }
            .navigationTitle("テンプレートから追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(AppStrings.actionCancel) {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(spacing: AppConstants.paddingSmall) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 40))
                .foregroundColor(AppColors.primary)
            
            Text("よく使うアイテムをまとめて追加")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Text("選択したアイテムが一括で追加されます")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.vertical, AppConstants.paddingMedium)
    }
    
    private func presetCategorySection(_ category: PresetCategory) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.paddingSmall) {
            // カテゴリヘッダー
            HStack {
                Text(category.name)
                    .font(AppFonts.subheadlineBold)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                // 全選択/全解除ボタン
                Button {
                    toggleAllInCategory(category)
                } label: {
                    Text(allSelectedInCategory(category) ? "全解除" : "全選択")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal, AppConstants.paddingMedium)
            
            // アイテムカード
            VStack(spacing: 0) {
                ForEach(category.items) { item in
                    presetItemRow(item)
                    
                    if item != category.items.last {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
            .background(AppColors.cardBackground)
            .cornerRadius(AppConstants.cornerRadiusMedium)
            .shadow(
                color: Color.black.opacity(AppConstants.shadowOpacity),
                radius: AppConstants.shadowRadius,
                x: 0,
                y: 2
            )
            .padding(.horizontal, AppConstants.paddingMedium)
        }
    }
    
    private func presetItemRow(_ item: PresetItem) -> some View {
        Button {
            hapticFeedback.impactOccurred()
            toggleSelection(item)
        } label: {
            HStack(spacing: AppConstants.paddingSmall) {
                // アイコン
                ZStack {
                    Circle()
                        .fill(isSelected(item) ? AppColors.primary.opacity(0.15) : AppColors.secondaryBackground)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: item.iconName)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected(item) ? AppColors.primary : AppColors.textSecondary)
                }
                
                // 情報
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("\(item.cycleDays)日ごと")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // チェックマーク
                ZStack {
                    Circle()
                        .stroke(isSelected(item) ? AppColors.primary : AppColors.textPlaceholder, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected(item) {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, AppConstants.paddingMedium)
            .padding(.vertical, AppConstants.paddingSmall)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var addButtonOverlay: some View {
        VStack {
            Spacer()
            
            Button {
                hapticFeedback.impactOccurred()
                addSelectedItems()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    
                    Text("\(selectedPresets.count)件を追加")
                        .font(AppFonts.bodyBold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.primary)
                .cornerRadius(AppConstants.cornerRadiusLarge)
                .shadow(color: AppColors.primary.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.horizontal, AppConstants.paddingLarge)
            .padding(.bottom, AppConstants.paddingLarge)
        }
    }
    
    // MARK: - Helper Methods
    
    private func isSelected(_ item: PresetItem) -> Bool {
        selectedPresets.contains(item)
    }
    
    private func toggleSelection(_ item: PresetItem) {
        if selectedPresets.contains(item) {
            selectedPresets.remove(item)
        } else {
            selectedPresets.insert(item)
        }
    }
    
    private func allSelectedInCategory(_ category: PresetCategory) -> Bool {
        category.items.allSatisfy { selectedPresets.contains($0) }
    }
    
    private func toggleAllInCategory(_ category: PresetCategory) {
        if allSelectedInCategory(category) {
            category.items.forEach { selectedPresets.remove($0) }
        } else {
            category.items.forEach { selectedPresets.insert($0) }
        }
        hapticFeedback.impactOccurred()
    }
    
    private func addSelectedItems() {
        let repository = ReminderItemRepository(context: viewContext)
        let categoryRepository = CategoryRepository(context: viewContext)
        let categories = categoryRepository.fetchAll()
        
        for preset in selectedPresets {
            // カテゴリを検索（なければ作成）
            let category = categories.first { $0.name == preset.categoryName }
            
            repository.create(
                name: preset.name,
                category: category,
                cycleDays: Int16(preset.cycleDays),
                dueDate: Date().adding(days: preset.cycleDays),
                iconName: preset.iconName,
                memo: nil,
                notifyBefore: 1,
                roomName: preset.roomName
            )
        }
        
        dismiss()
    }
}

#Preview {
    PresetSelectionView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
