//
//  HomeViewModel.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData
import Combine

/// ホーム画面のViewModel
@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 緊急アイテム（期限切れ + 今日 + 明日）
    @Published var urgentItems: [ReminderItem] = []
    
    /// カテゴリ別アイテム（緊急以外）
    @Published var itemsByCategory: [(category: Category?, items: [ReminderItem])] = []
    
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let repository: ReminderItemRepository
    private let categoryRepository: CategoryRepository
    
    // MARK: - Computed Properties
    
    /// すべてのアイテムが空かどうか
    var isEmpty: Bool {
        urgentItems.isEmpty && itemsByCategory.isEmpty
    }
    
    /// 緊急アイテム数（バッジ表示用）
    var urgentCount: Int {
        urgentItems.count
    }
    
    /// 緊急アイテムがあるか
    var hasUrgentItems: Bool {
        !urgentItems.isEmpty
    }
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.repository = ReminderItemRepository(context: context)
        self.categoryRepository = CategoryRepository(context: context)
        loadItems()
    }
    
    // MARK: - Public Methods
    
    /// アイテムを読み込む
    func loadItems() {
        isLoading = true
        
        let allItems = repository.fetchAll()
        let categories = categoryRepository.fetchAll()
        
        // 緊急アイテム（期限切れ、今日、明日）を抽出
        var urgent: [ReminderItem] = []
        var nonUrgent: [ReminderItem] = []
        
        for item in allItems {
            let status = DueStatus.from(date: item.dueDate)
            switch status {
            case .overdue, .today, .tomorrow:
                urgent.append(item)
            case .upcoming, .later:
                nonUrgent.append(item)
            }
        }
        
        // 緊急アイテムを期日順でソート
        self.urgentItems = urgent.sorted { 
            let status1 = DueStatus.from(date: $0.dueDate)
            let status2 = DueStatus.from(date: $1.dueDate)
            if status1.priority != status2.priority {
                return status1.priority < status2.priority
            }
            return ($0.dueDate ?? Date()) < ($1.dueDate ?? Date())
        }
        
        // カテゴリ別にグループ化
        var grouped: [(category: Category?, items: [ReminderItem])] = []
        
        for category in categories {
            let categoryItems = nonUrgent.filter { $0.category == category }
                .sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
            if !categoryItems.isEmpty {
                grouped.append((category: category, items: categoryItems))
            }
        }
        
        // カテゴリなしのアイテム
        let uncategorizedItems = nonUrgent.filter { $0.category == nil }
            .sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
        if !uncategorizedItems.isEmpty {
            grouped.append((category: nil, items: uncategorizedItems))
        }
        
        self.itemsByCategory = grouped
        
        isLoading = false
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
}
