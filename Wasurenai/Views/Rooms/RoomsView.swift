//
//  RoomsView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// 部屋別ビュー
struct RoomsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: RoomsViewModel
    @State private var showingItemDetail: ReminderItem? = nil
    @State private var showingCompleteAlert: ReminderItem? = nil
    
    init() {
        _viewModel = StateObject(wrappedValue: RoomsViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if viewModel.isEmpty {
                    emptyView
                } else {
                    mainContent
                }
            }
            .navigationTitle("部屋別")
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
            iconName: "location.slash",
            title: "アイテムがありません",
            subtitle: "アイテムを追加すると部屋別に表示されます"
        )
    }
    
    private var mainContent: some View {
        ScrollView {
            LazyVStack(spacing: AppConstants.paddingLarge) {
                ForEach(viewModel.itemsByRoom, id: \.room.objectID) { roomData in
                    roomSection(room: roomData.room, items: roomData.items)
                }
                
                // 未設定のアイテム
                if viewModel.hasUnassignedItems {
                    unassignedSection
                }
            }
            .padding(.vertical, AppConstants.paddingMedium)
        }
    }
    
    private func roomSection(room: Room, items: [ReminderItem]) -> some View {
        VStack(spacing: 0) {
            // 部屋ヘッダー
            HStack(spacing: AppConstants.paddingSmall) {
                ZStack {
                    Circle()
                        .fill(Color(hex: room.colorHex ?? AppColors.categoryColors[0]).opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: room.iconName ?? "house.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: room.colorHex ?? AppColors.categoryColors[0]))
                }
                
                Text(room.name ?? "")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(items.count)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(8)
                
                Spacer()
            }
            .padding(.horizontal, AppConstants.paddingMedium)
            .padding(.bottom, AppConstants.paddingSmall)
            
            // アイテムリスト
            VStack(spacing: AppConstants.paddingSmall) {
                ForEach(items, id: \.objectID) { item in
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
    
    private var unassignedSection: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack(spacing: AppConstants.paddingSmall) {
                ZStack {
                    Circle()
                        .fill(AppColors.textSecondary.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Text("未設定")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(viewModel.unassignedItems.count)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(8)
                
                Spacer()
            }
            .padding(.horizontal, AppConstants.paddingMedium)
            .padding(.bottom, AppConstants.paddingSmall)
            
            // アイテムリスト
            VStack(spacing: AppConstants.paddingSmall) {
                ForEach(viewModel.unassignedItems, id: \.objectID) { item in
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
}

#Preview {
    RoomsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
