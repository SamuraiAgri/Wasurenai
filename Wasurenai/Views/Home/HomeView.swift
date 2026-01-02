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
                
                // 部屋別セクション
                if !viewModel.itemsByRoom.isEmpty {
                    roomSection
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
    
    // MARK: - Room Section
    
    private var roomSection: some View {
        VStack(spacing: AppConstants.paddingMedium) {
            // セクションヘッダー
            HStack {
                Text(AppStrings.homeSectionByRoom)
                    .font(AppFonts.subheadlineBold)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
            }
            .padding(.horizontal, AppConstants.paddingMedium)
            .padding(.top, AppConstants.paddingSmall)
            
            // 部屋別カード
            ForEach(viewModel.itemsByRoom.indices, id: \.self) { index in
                let roomData = viewModel.itemsByRoom[index]
                RoomItemsCard(
                    room: roomData.room,
                    items: roomData.items,
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

// MARK: - Room Items Card

struct RoomItemsCard: View {
    
    let room: Room?
    let items: [ReminderItem]
    let onItemTap: (ReminderItem) -> Void
    let onComplete: (ReminderItem) -> Void
    let dueStatusProvider: (ReminderItem) -> DueStatus
    
    @State private var isExpanded: Bool = true
    
    private var roomColor: Color {
        if let hex = room?.colorHex {
            return Color(hex: hex)
        }
        return AppColors.textSecondary
    }
    
    private var roomName: String {
        room?.name ?? "未設定"
    }
    
    private var roomIcon: String {
        room?.iconName ?? "questionmark.circle.fill"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 部屋ヘッダー
            Button {
                withAnimation(AppConstants.springAnimation) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: AppConstants.paddingSmall) {
                    // 部屋アイコン
                    ZStack {
                        Circle()
                            .fill(roomColor.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: roomIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(roomColor)
                    }
                    
                    Text(roomName)
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
                        RoomItemRow(
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

// MARK: - Room Item Row

struct RoomItemRow: View {
    
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
