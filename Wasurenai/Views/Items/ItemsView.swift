//
//  ItemsView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// アイテム一覧画面
struct ItemsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ItemsViewModel
    @State private var showingAddItem = false
    @State private var showingPresetSelection = false
    @State private var showingItemDetail: ReminderItem? = nil
    @State private var showingDeleteAlert: ReminderItem? = nil
    @State private var showingCompleteAlert: ReminderItem? = nil
    
    init() {
        _viewModel = StateObject(wrappedValue: ItemsViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppColors.background
                    .ignoresSafeArea()
                
                if viewModel.isEmpty {
                    emptyView
                } else {
                    mainContent
                }
            }
            .navigationTitle(AppStrings.itemsTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // テンプレートから追加
                        Button {
                            showingPresetSelection = true
                        } label: {
                            Image(systemName: "sparkles.rectangle.stack")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        // 新規追加
                        addButton
                    }
                }
            }
            .searchable(
                text: $viewModel.searchText,
                prompt: AppStrings.itemsSearchPlaceholder
            )
            .refreshable {
                viewModel.loadData()
            }
            .sheet(isPresented: $showingAddItem) {
                ItemEditView()
                    .environment(\.managedObjectContext, viewContext)
                    .onDisappear {
                        viewModel.loadData()
                    }
            }
            .sheet(isPresented: $showingPresetSelection) {
                PresetSelectionView()
                    .environment(\.managedObjectContext, viewContext)
                    .onDisappear {
                        viewModel.loadData()
                    }
            }
            .sheet(item: $showingItemDetail) { item in
                ItemEditView(item: item)
                    .environment(\.managedObjectContext, viewContext)
                    .onDisappear {
                        viewModel.loadData()
                    }
            }
            .alert(AppStrings.alertDeleteTitle, isPresented: .init(
                get: { showingDeleteAlert != nil },
                set: { if !$0 { showingDeleteAlert = nil } }
            )) {
                Button(AppStrings.actionCancel, role: .cancel) { }
                Button(AppStrings.actionDelete, role: .destructive) {
                    if let item = showingDeleteAlert {
                        viewModel.deleteItem(item)
                    }
                }
            } message: {
                Text(AppStrings.alertDeleteItemMessage)
            }
            .alert(AppStrings.alertCompleteTitle, isPresented: .init(
                get: { showingCompleteAlert != nil },
                set: { if !$0 { showingCompleteAlert = nil } }
            )) {
                Button(AppStrings.actionCancel, role: .cancel) { }
                Button(AppStrings.actionComplete) {
                    if let item = showingCompleteAlert {
                        viewModel.completeItem(item)
                    }
                }
            } message: {
                Text(AppStrings.alertCompleteMessage)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    // MARK: - Subviews
    
    private var emptyView: some View {
        EmptyStateView(
            iconName: AppIcons.tabItemsOutline,
            title: AppStrings.itemsEmpty,
            subtitle: AppStrings.itemsEmptySubtitle,
            action: {
                showingAddItem = true
            },
            actionTitle: AppStrings.actionAdd
        )
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // カテゴリフィルター
            categoryFilterBar
            
            // アイテムリスト
            if viewModel.isFilteredEmpty {
                Spacer()
                Text("該当するアイテムがありません")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
            } else {
                itemsList
            }
        }
    }
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppConstants.paddingSmall) {
                AllCategoryChip(
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectAllCategories()
                }
                
                ForEach(viewModel.categories, id: \.objectID) { category in
                    CategoryChip(
                        title: category.name ?? "",
                        colorHex: category.colorHex,
                        iconName: category.iconName,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal, AppConstants.paddingMedium)
            .padding(.vertical, AppConstants.paddingSmall)
        }
        .background(AppColors.cardBackground)
    }
    
    private var itemsList: some View {
        ScrollView {
            LazyVStack(spacing: AppConstants.paddingSmall) {
                ForEach(viewModel.filteredItems, id: \.objectID) { item in
                    ReminderItemCard(
                        item: item,
                        dueStatus: viewModel.dueStatus(for: item),
                        onComplete: {
                            showingCompleteAlert = item
                        },
                        onTap: {
                            showingItemDetail = item
                        }
                    )
                    .contextMenu {
                        Button {
                            showingItemDetail = item
                        } label: {
                            Label(AppStrings.actionEdit, systemImage: AppIcons.edit)
                        }
                        
                        Button {
                            showingCompleteAlert = item
                        } label: {
                            Label(AppStrings.actionComplete, systemImage: AppIcons.checkCircle)
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = item
                        } label: {
                            Label(AppStrings.actionDelete, systemImage: AppIcons.delete)
                        }
                    }
                }
            }
            .padding(.horizontal, AppConstants.paddingMedium)
            .padding(.vertical, AppConstants.paddingSmall)
        }
    }
    
    private var addButton: some View {
        Button {
            showingAddItem = true
        } label: {
            Image(systemName: AppIcons.add)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.primary)
        }
    }
}

#Preview {
    ItemsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
