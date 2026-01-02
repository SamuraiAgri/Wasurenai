//
//  CategoryEditView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// カテゴリ編集・追加画面
struct CategoryEditView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CategoryEditViewModel
    @State private var showingDeleteAlert = false
    
    /// 新規作成用
    init() {
        _viewModel = StateObject(wrappedValue: CategoryEditViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    /// 編集用
    init(category: Category) {
        _viewModel = StateObject(wrappedValue: CategoryEditViewModel(
            context: PersistenceController.shared.container.viewContext,
            category: category
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 基本情報セクション
                basicInfoSection
                
                // カラー選択セクション
                colorSection
                
                // アイコン選択セクション
                iconSection
                
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
                Text(AppStrings.alertDeleteCategoryMessage)
            }
        }
    }
    
    // MARK: - Sections
    
    private var basicInfoSection: some View {
        Section {
            // プレビュー
            HStack {
                Spacer()
                categoryPreview
                Spacer()
            }
            .listRowBackground(Color.clear)
            
            // カテゴリ名
            HStack {
                Text(AppStrings.categoryName)
                    .foregroundColor(AppColors.textSecondary)
                TextField(AppStrings.categoryNamePlaceholder, text: $viewModel.name)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
    private var categoryPreview: some View {
        VStack(spacing: AppConstants.paddingSmall) {
            ZStack {
                Circle()
                    .fill(Color(hex: viewModel.selectedColorHex).opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: viewModel.selectedIconName)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(Color(hex: viewModel.selectedColorHex))
            }
            
            Text(viewModel.name.isEmpty ? AppStrings.categoryNamePlaceholder : viewModel.name)
                .font(AppFonts.bodyBold)
                .foregroundColor(viewModel.name.isEmpty ? AppColors.textPlaceholder : AppColors.textPrimary)
        }
        .padding(.vertical, AppConstants.paddingSmall)
    }
    
    private var colorSection: some View {
        Section(header: Text(AppStrings.categoryColor)) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                ForEach(AppColors.categoryColors, id: \.self) { colorHex in
                    colorCell(colorHex)
                }
            }
            .padding(.vertical, AppConstants.paddingSmall)
        }
    }
    
    private func colorCell(_ colorHex: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedColorHex = colorHex
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color(hex: colorHex))
                    .frame(width: 44, height: 44)
                
                if viewModel.selectedColorHex == colorHex {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: AppIcons.check)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconSection: some View {
        Section(header: Text(AppStrings.categoryIcon)) {
            IconPickerView(
                selectedIconName: $viewModel.selectedIconName,
                icons: AppIcons.categoryIcons,
                accentColor: Color(hex: viewModel.selectedColorHex)
            )
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
}

#Preview {
    CategoryEditView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
