//
//  ItemEditViewModel.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData
import Combine

/// アイテム編集画面のViewModel
@MainActor
final class ItemEditViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var name: String = ""
    @Published var selectedCategory: Category? = nil
    @Published var selectedRoom: Room? = nil
    @Published var cycleDays: Int = Int(AppConstants.defaultCycleDays)
    @Published var dueDate: Date = Date()
    @Published var selectedIconName: String = AppIcons.itemIcons[0]
    @Published var memo: String = ""
    @Published var notifyBefore: Int = Int(AppConstants.defaultNotifyBefore)
    @Published var notifyEnabled: Bool = true
    
    @Published var categories: [Category] = []
    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Properties
    
    private let repository: ReminderItemRepository
    private let categoryRepository: CategoryRepository
    private let editingItem: ReminderItem?
    
    /// 編集モードかどうか
    var isEditing: Bool {
        editingItem != nil
    }
    
    /// 保存可能かどうか
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 画面タイトル
    var title: String {
        isEditing ? AppStrings.itemDetailTitle : AppStrings.actionAdd
    }
    
    // MARK: - Init
    
    /// 新規作成用
    init(context: NSManagedObjectContext) {
        self.repository = ReminderItemRepository(context: context)
        self.categoryRepository = CategoryRepository(context: context)
        self.editingItem = nil
        
        loadCategories()
        setupDefaults()
    }
    
    /// 編集用
    init(context: NSManagedObjectContext, item: ReminderItem) {
        self.repository = ReminderItemRepository(context: context)
        self.categoryRepository = CategoryRepository(context: context)
        self.editingItem = item
        
        loadCategories()
        loadItemData(item)
    }
    
    // MARK: - Private Methods
    
    private func loadCategories() {
        categories = categoryRepository.fetchAll()
    }
    
    private func setupDefaults() {
        dueDate = Date().adding(days: cycleDays)
        if let firstCategory = categories.first {
            selectedCategory = firstCategory
        }
    }
    
    private func loadItemData(_ item: ReminderItem) {
        name = item.name ?? ""
        selectedCategory = item.category
        selectedRoom = RoomConstants.room(for: item.roomName)
        cycleDays = Int(item.cycleDays)
        dueDate = item.dueDate ?? Date()
        selectedIconName = item.iconName ?? AppIcons.itemIcons[0]
        memo = item.memo ?? ""
        notifyBefore = Int(item.notifyBefore)
        notifyEnabled = item.notifyBefore > 0
    }
    
    // MARK: - Public Methods
    
    /// サイクル日数を変更したとき、期日も更新
    func updateDueDateFromCycle() {
        if !isEditing {
            dueDate = Date().adding(days: cycleDays)
        }
    }
    
    /// アイテムを保存
    func save() {
        guard canSave else { return }
        
        isSaving = true
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let actualNotifyBefore = notifyEnabled ? Int16(notifyBefore) : 0
        
        if let item = editingItem {
            repository.update(
                item: item,
                name: trimmedName,
                category: selectedCategory,
                cycleDays: Int16(cycleDays),
                dueDate: dueDate,
                iconName: selectedIconName,
                memo: trimmedMemo.isEmpty ? nil : trimmedMemo,
                notifyBefore: actualNotifyBefore,
                roomName: selectedRoom?.name
            )
        } else {
            repository.create(
                name: trimmedName,
                category: selectedCategory,
                cycleDays: Int16(cycleDays),
                dueDate: dueDate,
                iconName: selectedIconName,
                memo: trimmedMemo.isEmpty ? nil : trimmedMemo,
                notifyBefore: actualNotifyBefore,
                roomName: selectedRoom?.name
            )
        }
        
        isSaving = false
    }
    
    /// アイテムを削除
    func delete() {
        guard let item = editingItem else { return }
        repository.delete(item: item)
    }
}
