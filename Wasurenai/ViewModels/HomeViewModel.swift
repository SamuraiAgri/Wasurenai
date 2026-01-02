//
//  HomeViewModel.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData
import Combine

/// ソート方法
enum SortOption: String, CaseIterable, Identifiable {
    case dueDate = "期日順"
    case priority = "優先度順"
    case name = "名前順"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .dueDate: return "calendar"
        case .priority: return "arrow.up.arrow.down"
        case .name: return "textformat"
        }
    }
}

/// ホーム画面のViewModel
@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 緊急アイテム（期限切れ + 今日 + 明日）
    @Published var urgentItems: [ReminderItem] = []
    
    /// 部屋別アイテム（緊急以外）
    @Published var itemsByRoom: [(room: Room?, items: [ReminderItem])] = []
    
    /// すべてのアイテム（フィルタ・ソート済み）
    @Published var filteredItems: [ReminderItem] = []
    
    @Published var isLoading: Bool = false
    
    /// 現在のソート方法
    @Published var sortOption: SortOption = .dueDate {
        didSet { applyFiltersAndSort() }
    }
    
    /// 部屋フィルター（nilは全部屋）
    @Published var filterRoom: Room? = nil {
        didSet { applyFiltersAndSort() }
    }
    
    /// 利用可能な部屋一覧
    @Published var availableRooms: [Room] = []
    
    // MARK: - Dependencies
    
    private let repository: ReminderItemRepository
    private let roomRepository: RoomRepository
    private var allItems: [ReminderItem] = []
    
    // MARK: - Computed Properties
    
    /// すべてのアイテムが空かどうか
    var isEmpty: Bool {
        urgentItems.isEmpty && itemsByRoom.isEmpty
    }
    
    /// フィルタ済みアイテムが空かどうか
    var isFilteredEmpty: Bool {
        filteredItems.isEmpty
    }
    
    /// 緊急アイテム数（バッジ表示用）
    var urgentCount: Int {
        urgentItems.count
    }
    
    /// 緊急アイテムがあるか
    var hasUrgentItems: Bool {
        !urgentItems.isEmpty
    }
    
    /// フィルターが適用されているか
    var isFiltering: Bool {
        filterRoom != nil
    }
    
    /// フィルターの説明テキスト
    var filterDescription: String {
        if let room = filterRoom {
            return room.name ?? "選択中"
        }
        return "すべての部屋"
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
        
        allItems = repository.fetchAll()
        availableRooms = roomRepository.fetchAll()
        
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
        
        for room in availableRooms {
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
        
        applyFiltersAndSort()
        
        isLoading = false
    }
    
    /// フィルターとソートを適用
    func applyFiltersAndSort() {
        var items = allItems
        
        // 部屋フィルター
        if let room = filterRoom {
            items = items.filter { $0.room?.objectID == room.objectID }
        }
        
        // ソート
        switch sortOption {
        case .dueDate:
            items.sort {
                let status1 = DueStatus.from(date: $0.dueDate)
                let status2 = DueStatus.from(date: $1.dueDate)
                if status1.priority != status2.priority {
                    return status1.priority < status2.priority
                }
                return ($0.dueDate ?? Date()) < ($1.dueDate ?? Date())
            }
        case .priority:
            items.sort {
                let priority1 = Priority.from($0.priority)
                let priority2 = Priority.from($1.priority)
                if priority1.sortOrder != priority2.sortOrder {
                    return priority1.sortOrder < priority2.sortOrder
                }
                // 同じ優先度なら期日順
                return ($0.dueDate ?? Date()) < ($1.dueDate ?? Date())
            }
        case .name:
            items.sort { ($0.name ?? "") < ($1.name ?? "") }
        }
        
        filteredItems = items
    }
    
    /// フィルターをクリア
    func clearFilter() {
        filterRoom = nil
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
