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
    @State private var showingSortSheet = false
    @State private var showingFilterSheet = false
    @State private var viewMode: ViewMode = .grouped
    
    private let hapticFeedback = UINotificationFeedbackGenerator()
    
    /// 表示モード
    enum ViewMode: String, CaseIterable {
        case grouped = "グループ"
        case list = "リスト"
        
        var iconName: String {
            switch self {
            case .grouped: return "square.grid.2x2"
            case .list: return "list.bullet"
            }
        }
    }
    
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
                    VStack(spacing: 0) {
                        // フィルター・ソートバー
                        filterSortBar
                        
                        // コンテンツ
                        if viewMode == .grouped {
                            scrollContent
                        } else {
                            listContent
                        }
                    }
                }
            }
            .navigationTitle("チェック")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Button {
                                withAnimation {
                                    viewMode = mode
                                }
                            } label: {
                                Label(mode.rawValue, systemImage: mode.iconName)
                            }
                        }
                    } label: {
                        Image(systemName: viewMode.iconName)
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
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
            .sheet(isPresented: $showingSortSheet) {
                sortSheet
            }
            .sheet(isPresented: $showingFilterSheet) {
                filterSheet
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
    
    // MARK: - Filter Sort Bar
    
    private var filterSortBar: some View {
        HStack(spacing: AppConstants.paddingSmall) {
            // ソートボタン
            Button {
                showingSortSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.sortOption.iconName)
                    Text(viewModel.sortOption.rawValue)
                        .font(AppFonts.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppColors.secondaryBackground)
                .cornerRadius(AppConstants.cornerRadiusSmall)
            }
            .foregroundColor(AppColors.textPrimary)
            
            // 部屋フィルターボタン
            Button {
                showingFilterSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text(viewModel.filterDescription)
                        .font(AppFonts.caption)
                        .lineLimit(1)
                    if viewModel.isFiltering {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(viewModel.isFiltering ? AppColors.primary.opacity(0.15) : AppColors.secondaryBackground)
                .cornerRadius(AppConstants.cornerRadiusSmall)
            }
            .foregroundColor(viewModel.isFiltering ? AppColors.primary : AppColors.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, AppConstants.paddingMedium)
        .padding(.vertical, AppConstants.paddingSmall)
    }
    
    // MARK: - Sort Sheet
    
    private var sortSheet: some View {
        NavigationStack {
            List {
                ForEach(SortOption.allCases) { option in
                    Button {
                        viewModel.sortOption = option
                        showingSortSheet = false
                    } label: {
                        HStack {
                            Image(systemName: option.iconName)
                                .foregroundColor(AppColors.primary)
                                .frame(width: 30)
                            Text(option.rawValue)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            if viewModel.sortOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("並び替え")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.actionDone) {
                        showingSortSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Filter Sheet
    
    private var filterSheet: some View {
        NavigationStack {
            List {
                Button {
                    viewModel.filterRoom = nil
                    showingFilterSheet = false
                } label: {
                    HStack {
                        Image(systemName: "house.fill")
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: 30)
                        Text("すべての部屋")
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        if viewModel.filterRoom == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
                
                ForEach(viewModel.availableRooms, id: \.objectID) { room in
                    Button {
                        viewModel.filterRoom = room
                        showingFilterSheet = false
                    } label: {
                        HStack {
                            Image(systemName: room.iconName ?? "house.fill")
                                .foregroundColor(Color(hex: room.colorHex ?? "#666666"))
                                .frame(width: 30)
                            Text(room.name ?? "")
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            if viewModel.filterRoom?.objectID == room.objectID {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("部屋でフィルター")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.actionDone) {
                        showingFilterSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - List Content (Flat List View)
    
    private var listContent: some View {
        ScrollView {
            if viewModel.isFilteredEmpty {
                VStack(spacing: AppConstants.paddingMedium) {
                    Spacer(minLength: 100)
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.textPlaceholder)
                    Text("該当するアイテムがありません")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                    if viewModel.isFiltering {
                        Button("フィルターをクリア") {
                            viewModel.clearFilter()
                        }
                        .foregroundColor(AppColors.primary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: AppConstants.paddingSmall) {
                    ForEach(viewModel.filteredItems, id: \.objectID) { item in
                        FilteredItemCard(
                            item: item,
                            dueStatus: viewModel.dueStatus(for: item),
                            onTap: {
                                showingItemDetail = item
                            },
                            onComplete: {
                                showingCompleteAlert = item
                            }
                        )
                        .padding(.horizontal, AppConstants.paddingMedium)
                    }
                }
                .padding(.vertical, AppConstants.paddingSmall)
            }
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

// MARK: - Filtered Item Card

struct FilteredItemCard: View {
    
    let item: ReminderItem
    let dueStatus: DueStatus
    let onTap: () -> Void
    let onComplete: () -> Void
    
    private var priority: Priority {
        Priority.from(item.priority)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppConstants.paddingSmall) {
                // 優先度インジケーター
                Rectangle()
                    .fill(priority.color)
                    .frame(width: 4)
                    .cornerRadius(2)
                
                // アイコン
                ZStack {
                    Circle()
                        .fill(dueStatus.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: item.iconName ?? "circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(dueStatus.color)
                }
                
                // 情報
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name ?? "")
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        // 部屋
                        if let room = item.room {
                            HStack(spacing: 2) {
                                Image(systemName: room.iconName ?? "house.fill")
                                    .font(.system(size: 10))
                                Text(room.name ?? "")
                                    .font(AppFonts.caption)
                            }
                            .foregroundColor(AppColors.textSecondary)
                        }
                        
                        // 優先度
                        HStack(spacing: 2) {
                            Image(systemName: priority.iconName)
                                .font(.system(size: 10))
                            Text(priority.displayName)
                                .font(AppFonts.caption)
                        }
                        .foregroundColor(priority.color)
                    }
                }
                
                Spacer()
                
                // 期日
                VStack(alignment: .trailing, spacing: 2) {
                    Text(dueStatus.displayText)
                        .font(AppFonts.captionBold)
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
                        .font(.system(size: 26))
                        .foregroundColor(AppColors.success)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, AppConstants.paddingSmall)
            .padding(.horizontal, AppConstants.paddingSmall)
            .background(AppColors.cardBackground)
            .cornerRadius(AppConstants.cornerRadiusMedium)
            .shadow(
                color: Color.black.opacity(AppConstants.shadowOpacity),
                radius: AppConstants.shadowRadius,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
