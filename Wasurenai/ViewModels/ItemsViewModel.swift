//
//  ItemsViewModel.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData
import Combine

/// アイテム一覧画面のViewModel
@MainActor
final class ItemsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var items: [ReminderItem] = []
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category? = nil
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let itemRepository: ReminderItemRepository
    private let categoryRepository: CategoryRepository
    
    // MARK: - Computed Properties
    
    /// フィルタリング後のアイテム
    var filteredItems: [ReminderItem] {
        var result = items
        
        // カテゴリフィルタ
        if let category = selectedCategory {
            result = result.filter { $0.category?.objectID == category.objectID }
        }
        
        // 検索フィルタ
        if !searchText.isEmpty {
            result = result.filter { item in
                item.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        return result
    }
    
    /// アイテムが空かどうか
    var isEmpty: Bool {
        items.isEmpty
    }
    
    /// フィルタリング後のアイテムが空かどうか
    var isFilteredEmpty: Bool {
        filteredItems.isEmpty
    }
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.itemRepository = ReminderItemRepository(context: context)
        self.categoryRepository = CategoryRepository(context: context)
        loadData()
    }
    
    // MARK: - Public Methods
    
    /// データを読み込む
    func loadData() {
        isLoading = true
        items = itemRepository.fetchAll()
        categories = categoryRepository.fetchAll()
        isLoading = false
    }
    
    /// カテゴリを選択
    func selectCategory(_ category: Category?) {
        selectedCategory = category
    }
    
    /// すべてのカテゴリを表示
    func selectAllCategories() {
        selectedCategory = nil
    }
    
    /// アイテムを削除
    func deleteItem(_ item: ReminderItem) {
        itemRepository.delete(item: item)
        loadData()
    }
    
    /// アイテムを完了にする
    func completeItem(_ item: ReminderItem) {
        itemRepository.complete(item: item)
        loadData()
    }
    
    /// 期日のステータスを取得
    func dueStatus(for item: ReminderItem) -> DueStatus {
        DueStatus.from(date: item.dueDate)
    }
}
