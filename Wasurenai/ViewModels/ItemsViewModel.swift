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
    @Published var rooms: [Room] = []
    @Published var selectedRoom: Room? = nil
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let itemRepository: ReminderItemRepository
    private let roomRepository: RoomRepository
    
    // MARK: - Computed Properties
    
    /// フィルタリング後のアイテム
    var filteredItems: [ReminderItem] {
        var result = items
        
        // 部屋フィルタ
        if let room = selectedRoom {
            result = result.filter { $0.room?.objectID == room.objectID }
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
        self.roomRepository = RoomRepository(context: context)
        loadData()
    }
    
    // MARK: - Public Methods
    
    /// データを読み込む
    func loadData() {
        isLoading = true
        items = itemRepository.fetchAll()
        rooms = roomRepository.fetchAll()
        isLoading = false
    }
    
    /// 部屋を選択
    func selectRoom(_ room: Room?) {
        selectedRoom = room
    }
    
    /// すべての部屋を表示
    func selectAllRooms() {
        selectedRoom = nil
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
