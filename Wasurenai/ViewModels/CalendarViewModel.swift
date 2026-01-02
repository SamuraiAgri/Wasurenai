//
//  CalendarViewModel.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData
import Combine

/// カレンダー画面のViewModel
@MainActor
final class CalendarViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var itemsByDate: [Date: [ReminderItem]] = [:]
    @Published var selectedDateItems: [ReminderItem] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let repository: ReminderItemRepository
    private let context: NSManagedObjectContext
    
    // MARK: - Computed Properties
    
    /// 現在の月の日付配列
    var daysInMonth: [Date] {
        generateDaysInMonth(for: currentMonth)
    }
    
    /// 月の表示文字列
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: currentMonth)
    }
    
    /// 曜日ラベル
    let weekdaySymbols: [String] = ["日", "月", "火", "水", "木", "金", "土"]
    
    /// 選択日の表示文字列
    var selectedDateString: String {
        selectedDate.dateWithWeekdayString
    }
    
    /// 選択日にアイテムがあるか
    var hasItemsOnSelectedDate: Bool {
        !selectedDateItems.isEmpty
    }
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.repository = ReminderItemRepository(context: context)
        loadItems()
    }
    
    // MARK: - Public Methods
    
    /// アイテムを読み込む
    func loadItems() {
        isLoading = true
        
        let allItems = repository.fetchAll()
        
        // 日付ごとにグループ化
        var grouped: [Date: [ReminderItem]] = [:]
        for item in allItems {
            guard let dueDate = item.dueDate else { continue }
            let dateKey = Calendar.current.startOfDay(for: dueDate)
            if grouped[dateKey] == nil {
                grouped[dateKey] = []
            }
            grouped[dateKey]?.append(item)
        }
        
        itemsByDate = grouped
        updateSelectedDateItems()
        
        isLoading = false
    }
    
    /// 日付を選択
    func selectDate(_ date: Date) {
        selectedDate = Calendar.current.startOfDay(for: date)
        updateSelectedDateItems()
    }
    
    /// 前月へ移動
    func goToPreviousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    /// 次月へ移動
    func goToNextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    /// 今日へ移動
    func goToToday() {
        currentMonth = Date()
        selectDate(Date())
    }
    
    /// 指定日のアイテム数を取得
    func itemCount(for date: Date) -> Int {
        let dateKey = Calendar.current.startOfDay(for: date)
        return itemsByDate[dateKey]?.count ?? 0
    }
    
    /// 指定日にアイテムがあるか
    func hasItems(on date: Date) -> Bool {
        itemCount(for: date) > 0
    }
    
    /// 指定日の期日ステータスを取得（最も緊急なもの）
    func mostUrgentStatus(for date: Date) -> DueStatus? {
        let dateKey = Calendar.current.startOfDay(for: date)
        guard let items = itemsByDate[dateKey], !items.isEmpty else { return nil }
        
        return items
            .map { DueStatus.from(date: $0.dueDate) }
            .min { $0.priority < $1.priority }
    }
    
    /// アイテムを完了にする
    func completeItem(_ item: ReminderItem) {
        repository.complete(item: item)
        loadItems()
    }
    
    /// アイテムを削除する
    func deleteItem(_ item: ReminderItem) {
        repository.delete(item: item)
        loadItems()
    }
    
    /// 期日のステータスを取得
    func dueStatus(for item: ReminderItem) -> DueStatus {
        DueStatus.from(date: item.dueDate)
    }
    
    // MARK: - Private Methods
    
    private func updateSelectedDateItems() {
        let dateKey = Calendar.current.startOfDay(for: selectedDate)
        selectedDateItems = itemsByDate[dateKey] ?? []
    }
    
    private func generateDaysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else { return [] }
        
        var days: [Date] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate < monthLastWeek.end {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return days
    }
}
