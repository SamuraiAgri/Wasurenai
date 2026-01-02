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
    
    /// 部屋別アイテム（緊急以外）
    @Published var itemsByRoom: [(room: Room?, items: [ReminderItem])] = []
    
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let repository: ReminderItemRepository
    private let roomRepository: RoomRepository
    
    // MARK: - Computed Properties
    
    /// すべてのアイテムが空かどうか
    var isEmpty: Bool {
        urgentItems.isEmpty && itemsByRoom.isEmpty
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
        self.roomRepository = RoomRepository(context: context)
        loadItems()
    }
    
    // MARK: - Public Methods
    
    /// アイテムを読み込む
    func loadItems() {
        isLoading = true
        
        let allItems = repository.fetchAll()
        let rooms = roomRepository.fetchAll()
        
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
        
        // 部屋別にグループ化
        var grouped: [(room: Room?, items: [ReminderItem])] = []
        
        for room in rooms {
            let roomItems = nonUrgent.filter { $0.room?.objectID == room.objectID }
                .sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
            if !roomItems.isEmpty {
                grouped.append((room: room, items: roomItems))
            }
        }
        
        // 部屋なしのアイテム
        let unassignedItems = nonUrgent.filter { $0.room == nil }
            .sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
        if !unassignedItems.isEmpty {
            grouped.append((room: nil, items: unassignedItems))
        }
        
        self.itemsByRoom = grouped
        
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
