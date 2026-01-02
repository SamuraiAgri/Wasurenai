//
//  CalendarView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// カレンダー画面
struct CalendarView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CalendarViewModel
    @State private var showingAddItem = false
    @State private var showingItemDetail: ReminderItem? = nil
    @State private var showingCompleteAlert: ReminderItem? = nil
    
    init() {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // カレンダーヘッダー
                    calendarHeader
                    
                    // 曜日ラベル
                    weekdayHeader
                    
                    // カレンダーグリッド
                    calendarGrid
                    
                    Divider()
                        .padding(.top, 8)
                    
                    // 選択日のアイテムリスト
                    selectedDateSection
                }
            }
            .navigationTitle("カレンダー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    todayButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAddItem) {
                ItemEditView()
                    .environment(\.managedObjectContext, viewContext)
                    .onDisappear {
                        viewModel.loadItems()
                    }
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
    
    // MARK: - Calendar Header
    
    private var calendarHeader: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.goToPreviousMonth()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text(viewModel.monthYearString)
                .font(AppFonts.title2)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.goToNextMonth()
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, AppConstants.paddingMedium)
        .padding(.vertical, AppConstants.paddingSmall)
    }
    
    // MARK: - Weekday Header
    
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.weekdaySymbols.indices, id: \.self) { index in
                Text(viewModel.weekdaySymbols[index])
                    .font(AppFonts.caption)
                    .foregroundColor(weekdayColor(for: index))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, AppConstants.paddingSmall)
        .padding(.vertical, AppConstants.paddingSmall)
    }
    
    private func weekdayColor(for index: Int) -> Color {
        if index == 0 { return AppColors.danger } // 日曜
        if index == 6 { return AppColors.primary } // 土曜
        return AppColors.textSecondary
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        
        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(viewModel.daysInMonth, id: \.self) { date in
                CalendarDayCell(
                    date: date,
                    isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                    isCurrentMonth: Calendar.current.isDate(date, equalTo: viewModel.currentMonth, toGranularity: .month),
                    isToday: Calendar.current.isDateInToday(date),
                    itemCount: viewModel.itemCount(for: date),
                    urgentStatus: viewModel.mostUrgentStatus(for: date)
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectDate(date)
                    }
                }
            }
        }
        .padding(.horizontal, AppConstants.paddingSmall)
    }
    
    // MARK: - Selected Date Section
    
    private var selectedDateSection: some View {
        VStack(spacing: 0) {
            // 選択日ヘッダー
            HStack {
                Text(viewModel.selectedDateString)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if !viewModel.hasItemsOnSelectedDate {
                    Button {
                        showingAddItem = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: AppIcons.addCircle)
                            Text("追加")
                        }
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.primary)
                    }
                }
            }
            .padding(.horizontal, AppConstants.paddingMedium)
            .padding(.vertical, AppConstants.paddingSmall)
            
            // アイテムリスト
            if viewModel.hasItemsOnSelectedDate {
                ScrollView {
                    LazyVStack(spacing: AppConstants.paddingSmall) {
                        ForEach(viewModel.selectedDateItems, id: \.objectID) { item in
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
                        }
                    }
                    .padding(.horizontal, AppConstants.paddingMedium)
                    .padding(.bottom, AppConstants.paddingMedium)
                }
            } else {
                VStack(spacing: AppConstants.paddingSmall) {
                    Spacer()
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.textPlaceholder)
                    Text("この日の予定はありません")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Toolbar Buttons
    
    private var todayButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.goToToday()
            }
        } label: {
            Text("今日")
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.primary)
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

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    let itemCount: Int
    let urgentStatus: DueStatus?
    let action: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var textColor: Color {
        if !isCurrentMonth { return AppColors.textPlaceholder }
        if isSelected { return .white }
        if isToday { return AppColors.primary }
        
        let weekday = Calendar.current.component(.weekday, from: date)
        if weekday == 1 { return AppColors.danger } // 日曜
        if weekday == 7 { return AppColors.primary } // 土曜
        
        return AppColors.textPrimary
    }
    
    private var backgroundColor: Color {
        if isSelected { return AppColors.primary }
        if isToday { return AppColors.primary.opacity(0.1) }
        return .clear
    }
    
    private var dotColor: Color {
        guard let status = urgentStatus else { return .clear }
        return status.color
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(isToday || isSelected ? AppFonts.subheadlineBold : AppFonts.subheadline)
                    .foregroundColor(textColor)
                    .frame(width: 32, height: 32)
                    .background(backgroundColor)
                    .clipShape(Circle())
                
                // アイテムドット
                if itemCount > 0 && isCurrentMonth {
                    HStack(spacing: 2) {
                        ForEach(0..<min(itemCount, 3), id: \.self) { _ in
                            Circle()
                                .fill(isSelected ? .white.opacity(0.8) : dotColor)
                                .frame(width: 5, height: 5)
                        }
                    }
                    .frame(height: 6)
                } else {
                    Spacer()
                        .frame(height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CalendarView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
