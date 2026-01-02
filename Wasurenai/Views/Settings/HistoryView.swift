//
//  HistoryView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// 完了履歴画面
struct HistoryView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: HistoryViewModel
    @State private var showingClearAlert = false
    
    init() {
        _viewModel = StateObject(wrappedValue: HistoryViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if viewModel.isEmpty {
                    emptyView
                } else {
                    historyList
                }
            }
            .navigationTitle("完了履歴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(AppStrings.actionClose) {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                
                if !viewModel.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(role: .destructive) {
                                showingClearAlert = true
                            } label: {
                                Label("すべて削除", systemImage: AppIcons.delete)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
            }
            .alert("履歴をすべて削除", isPresented: $showingClearAlert) {
                Button(AppStrings.actionCancel, role: .cancel) { }
                Button("削除", role: .destructive) {
                    viewModel.clearAllHistories()
                }
            } message: {
                Text("すべての完了履歴が削除されます。この操作は取り消せません。")
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyView: some View {
        VStack(spacing: AppConstants.paddingMedium) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textPlaceholder)
            
            Text("まだ完了履歴がありません")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textSecondary)
            
            Text("アイテムを完了すると履歴が記録されます")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textPlaceholder)
        }
    }
    
    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: AppConstants.paddingLarge, pinnedViews: .sectionHeaders) {
                ForEach(viewModel.groupedHistories, id: \.month) { group in
                    Section {
                        VStack(spacing: 0) {
                            ForEach(group.histories, id: \.objectID) { history in
                                historyRow(history)
                                
                                if history != group.histories.last {
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
                    } header: {
                        monthHeader(group.month, count: group.histories.count)
                    }
                }
            }
            .padding(.vertical, AppConstants.paddingMedium)
        }
    }
    
    private func monthHeader(_ date: Date, count: Int) -> some View {
        HStack {
            Text(viewModel.monthString(for: date))
                .font(AppFonts.subheadlineBold)
                .foregroundColor(AppColors.textSecondary)
            
            Text("\(count)件")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textPlaceholder)
            
            Spacer()
        }
        .padding(.horizontal, AppConstants.paddingMedium)
        .padding(.vertical, AppConstants.paddingSmall)
        .background(AppColors.background)
    }
    
    private func historyRow(_ history: CompletionHistory) -> some View {
        HStack(spacing: AppConstants.paddingSmall) {
            // アイコン
            ZStack {
                Circle()
                    .fill(AppColors.success.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: history.item?.iconName ?? AppIcons.checkCircle)
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.success)
            }
            
            // 情報
            VStack(alignment: .leading, spacing: 2) {
                Text(history.itemName ?? history.item?.name ?? "不明なアイテム")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                if let category = history.item?.category {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: category.colorHex ?? AppColors.categoryColors[0]))
                            .frame(width: 8, height: 8)
                        Text(category.name ?? "")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // 日時
            if let date = history.completedAt {
                Text(formatDate(date))
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, AppConstants.paddingMedium)
        .padding(.vertical, AppConstants.paddingSmall)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "今日 HH:mm"
        } else if Calendar.current.isDateInYesterday(date) {
            formatter.dateFormat = "昨日 HH:mm"
        } else {
            formatter.dateFormat = "M/d HH:mm"
        }
        
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
}
