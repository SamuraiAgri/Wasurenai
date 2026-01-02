//
//  HomeView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// ホーム画面
struct HomeView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HomeViewModel
    @State private var showingItemDetail: ReminderItem? = nil
    @State private var showingCompleteAlert: ReminderItem? = nil
    
    private let hapticFeedback = UINotificationFeedbackGenerator()
    
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel(context: PersistenceController.shared.container.viewContext))
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
                    scrollContent
                }
            }
            .navigationTitle(AppStrings.homeTitle)
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.loadItems()
            }
            .sheet(item: $showingItemDetail) { item in
                ItemEditView(item: item)
                    .environment(\.managedObjectContext, viewContext)
                    .onDisappear {
                        viewModel.loadItems()
                    }
            }
            .alert(AppStrings.alertCompleteTitle, isPresented: .init(
                get: { showingCompleteAlert != nil },
                set: { if !$0 { showingCompleteAlert = nil } }
            )) {
                Button(AppStrings.actionCancel, role: .cancel) { }
                Button(AppStrings.actionComplete) {
                    if let item = showingCompleteAlert {
                        hapticFeedback.notificationOccurred(.success)
                        viewModel.completeItem(item)
                    }
                }
            } message: {
                Text(AppStrings.alertCompleteMessage)
            }
        }
        .onAppear {
            viewModel.loadItems()
        }
    }
    
    // MARK: - Subviews
    
    private var emptyView: some View {
        EmptyStateView(
            iconName: AppIcons.tabItemsOutline,
            title: AppStrings.homeEmpty,
            subtitle: AppStrings.homeEmptySubtitle
        )
    }
    
    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: AppConstants.paddingMedium) {
                // 緊急セクション（期限切れ・今日・明日）
                if viewModel.hasUrgentItems {
                    urgentSection
                }
                
                // カテゴリ別セクション
                if !viewModel.itemsByCategory.isEmpty {
                    categorySection
                }
            }
            .padding(.bottom, AppConstants.paddingLarge)
        }
    }
    
    // MARK: - Urgent Section
    
    private var urgentSection: some View {
        VStack(spacing: 0) {
            SectionHeaderView(
                title: AppStrings.homeSectionUrgent,
                iconName: AppIcons.warning,
                color: AppColors.danger,
                count: viewModel.urgentCount
            )
            
            VStack(spacing: AppConstants.paddingSmall) {
                ForEach(viewModel.urgentItems, id: \.objectID) { item in
                    SwipeableItemCard(
                        item: item,
                        dueStatus: viewModel.dueStatus(for: item),
                        onComplete: {
                            showingCompleteAlert = item
                        },
                        onEdit: {
                            showingItemDetail = item
                        },
                        onDelete: {
                            viewModel.deleteItem(item)
                        }
                    )
                    .padding(.horizontal, AppConstants.paddingMedium)
                }
            }
        }
    }
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        VStack(spacing: AppConstants.paddingMedium) {
            // セクションヘッダー
            HStack {
                Text(AppStrings.homeSectionByCategory)
                    .font(AppFonts.subheadlineBold)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
            }
            .padding(.horizontal, AppConstants.paddingMedium)
            .padding(.top, AppConstants.paddingSmall)
            
            // カテゴリ別カード
            ForEach(viewModel.itemsByCategory.indices, id: \.self) { index in
                let categoryData = viewModel.itemsByCategory[index]
                CategoryItemsCard(
                    category: categoryData.category,
                    items: categoryData.items,
                    onItemTap: { item in
                        showingItemDetail = item
                    },
                    onComplete: { item in
                        showingCompleteAlert = item
                    },
                    dueStatusProvider: { item in
                        viewModel.dueStatus(for: item)
                    }
                )
            }
        }
    }
}

// MARK: - Category Items Card

struct CategoryItemsCard: View {
    
    let category: Category?
    let items: [ReminderItem]
    let onItemTap: (ReminderItem) -> Void
    let onComplete: (ReminderItem) -> Void
    let dueStatusProvider: (ReminderItem) -> DueStatus
    
    @State private var isExpanded: Bool = true
    
    private var categoryColor: Color {
        if let hex = category?.colorHex {
            return Color(hex: hex)
        }
        return AppColors.textSecondary
    }
    
    private var categoryName: String {
        category?.name ?? AppStrings.categoryNone
    }
    
    private var categoryIcon: String {
        category?.iconName ?? "folder.fill"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // カテゴリヘッダー
            Button {
                withAnimation(AppConstants.springAnimation) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: AppConstants.paddingSmall) {
                    // カテゴリアイコン
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: categoryIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(categoryColor)
                    }
                    
                    Text(categoryName)
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("\(items.count)")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColors.secondaryBackground)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(AppConstants.paddingMedium)
            }
            .buttonStyle(PlainButtonStyle())
            
            // アイテムリスト（展開時）
            if isExpanded {
                Divider()
                    .padding(.horizontal, AppConstants.paddingMedium)
                
                VStack(spacing: 0) {
                    ForEach(items, id: \.objectID) { item in
                        CategoryItemRow(
                            item: item,
                            dueStatus: dueStatusProvider(item),
                            onTap: { onItemTap(item) },
                            onComplete: { onComplete(item) }
                        )
                        
                        if item != items.last {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
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

// MARK: - Category Item Row

struct CategoryItemRow: View {
    
    let item: ReminderItem
    let dueStatus: DueStatus
    let onTap: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppConstants.paddingSmall) {
                // アイコン
                Image(systemName: item.iconName ?? "circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 40)
                
                // アイテム名
                Text(item.name ?? "")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                // 期日
                VStack(alignment: .trailing, spacing: 2) {
                    Text(dueStatus.displayText)
                        .font(AppFonts.caption)
                        .foregroundColor(dueStatus.color)
                    
                    if let date = item.dueDate {
                        Text(date.shortDateString)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // 完了ボタン
                Button(action: onComplete) {
                    Image(systemName: AppIcons.checkCircle)
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.success.opacity(0.7))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, AppConstants.paddingMedium)
            .padding(.vertical, AppConstants.paddingSmall)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
