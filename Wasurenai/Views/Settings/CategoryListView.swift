//
//  CategoryListView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// カテゴリ一覧画面
struct CategoryListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CategoryViewModel
    @State private var showingAddCategory = false
    @State private var showingEditCategory: Category? = nil
    @State private var showingDeleteAlert: Category? = nil
    
    init() {
        _viewModel = StateObject(wrappedValue: CategoryViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        List {
            if viewModel.isEmpty {
                emptyView
            } else {
                categoriesSection
            }
        }
        .navigationTitle(AppStrings.categoryTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                addButton
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryEditView()
                .environment(\.managedObjectContext, viewContext)
                .onDisappear {
                    viewModel.loadCategories()
                }
        }
        .sheet(item: $showingEditCategory) { category in
            CategoryEditView(category: category)
                .environment(\.managedObjectContext, viewContext)
                .onDisappear {
                    viewModel.loadCategories()
                }
        }
        .alert(AppStrings.alertDeleteTitle, isPresented: .init(
            get: { showingDeleteAlert != nil },
            set: { if !$0 { showingDeleteAlert = nil } }
        )) {
            Button(AppStrings.actionCancel, role: .cancel) { }
            Button(AppStrings.actionDelete, role: .destructive) {
                if let category = showingDeleteAlert {
                    viewModel.deleteCategory(category)
                }
            }
        } message: {
            Text(AppStrings.alertDeleteCategoryMessage)
        }
        .onAppear {
            viewModel.loadCategories()
        }
    }
    
    // MARK: - Subviews
    
    private var emptyView: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: AppConstants.paddingSmall) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textPlaceholder)
                    Text(AppStrings.categoryEmpty)
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.vertical, AppConstants.paddingLarge)
                Spacer()
            }
        }
    }
    
    private var categoriesSection: some View {
        Section {
            ForEach(viewModel.categories, id: \.objectID) { category in
                categoryRow(category)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingEditCategory = category
                    }
            }
            .onMove { source, destination in
                viewModel.moveCategory(from: source, to: destination)
            }
            .onDelete { indexSet in
                if let index = indexSet.first {
                    showingDeleteAlert = viewModel.categories[index]
                }
            }
        }
    }
    
    private func categoryRow(_ category: Category) -> some View {
        HStack(spacing: AppConstants.paddingMedium) {
            // アイコン
            ZStack {
                Circle()
                    .fill(Color(hex: category.colorHex ?? AppColors.categoryColors[0]).opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: category.iconName ?? AppIcons.categoryIcons[0])
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: category.colorHex ?? AppColors.categoryColors[0]))
            }
            
            // カテゴリ名
            Text(category.name ?? "")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            // アイテム数
            let itemCount = (category.items as? Set<ReminderItem>)?.count ?? 0
            if itemCount > 0 {
                Text("\(itemCount)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(8)
            }
            
            Image(systemName: AppIcons.chevronRight)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textPlaceholder)
        }
        .padding(.vertical, 4)
    }
    
    private var addButton: some View {
        Button {
            showingAddCategory = true
        } label: {
            Image(systemName: AppIcons.add)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.primary)
        }
    }
}

#Preview {
    NavigationStack {
        CategoryListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
