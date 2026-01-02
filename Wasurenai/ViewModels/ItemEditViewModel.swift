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
    @Published var selectedRoom: Room? = nil
    @Published var cycleDays: Int = Int(AppConstants.defaultCycleDays)
    @Published var dueDate: Date = Date()
    @Published var selectedIconName: String = AppIcons.itemIcons[0]
    @Published var memo: String = ""
    @Published var notifyBefore: Int = Int(AppConstants.defaultNotifyBefore)
    @Published var notifyEnabled: Bool = true
    @Published var priority: Priority = .medium
    
    @Published var rooms: [Room] = []
    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Properties
    
    private let repository: ReminderItemRepository
    private let roomRepository: RoomRepository
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
        self.roomRepository = RoomRepository(context: context)
        self.editingItem = nil
        
        loadRooms()
        setupDefaults()
    }
    
    /// 編集用
    init(context: NSManagedObjectContext, item: ReminderItem) {
        self.repository = ReminderItemRepository(context: context)
        self.roomRepository = RoomRepository(context: context)
        self.editingItem = item
        
        loadRooms()
        loadItemData(item)
    }
    
    /// プリセットから作成
    init(context: NSManagedObjectContext, preset: PresetItem) {
        self.repository = ReminderItemRepository(context: context)
        self.roomRepository = RoomRepository(context: context)
        self.editingItem = nil
        
        loadRooms()
        loadPresetData(preset)
    }
    
    // MARK: - Private Methods
    
    private func loadRooms() {
        rooms = roomRepository.fetchAll()
    }
    
    private func setupDefaults() {
        dueDate = Date().adding(days: cycleDays)
        if let firstRoom = rooms.first {
            selectedRoom = firstRoom
        }
    }
    
    private func loadItemData(_ item: ReminderItem) {
        name = item.name ?? ""
        selectedRoom = item.room
        cycleDays = Int(item.cycleDays)
        dueDate = item.dueDate ?? Date()
        selectedIconName = item.iconName ?? AppIcons.itemIcons[0]
        memo = item.memo ?? ""
        notifyBefore = Int(item.notifyBefore)
        notifyEnabled = item.notifyBefore > 0
        priority = Priority.from(item.priority)
    }
    
    private func loadPresetData(_ preset: PresetItem) {
        name = preset.name
        selectedIconName = preset.iconName
        cycleDays = preset.cycleDays
        dueDate = Date().adding(days: cycleDays)
        
        // 部屋名で検索してセット
        if let room = roomRepository.findByName(preset.roomName) {
            selectedRoom = room
        } else if let firstRoom = rooms.first {
            selectedRoom = firstRoom
        }
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
                room: selectedRoom,
                cycleDays: Int16(cycleDays),
                dueDate: dueDate,
                iconName: selectedIconName,
                memo: trimmedMemo.isEmpty ? nil : trimmedMemo,
                notifyBefore: actualNotifyBefore,
                priority: priority
            )
        } else {
            repository.create(
                name: trimmedName,
                room: selectedRoom,
                cycleDays: Int16(cycleDays),
                dueDate: dueDate,
                iconName: selectedIconName,
                memo: trimmedMemo.isEmpty ? nil : trimmedMemo,
                notifyBefore: actualNotifyBefore,
                priority: priority
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
