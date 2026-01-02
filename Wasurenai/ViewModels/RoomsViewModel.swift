//
//  RoomsViewModel.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData
import Combine

/// 部屋別ビューのViewModel
@MainActor
final class RoomsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var rooms: [Room] = []
    @Published var itemsByRoom: [(room: Room, items: [ReminderItem])] = []
    @Published var unassignedItems: [ReminderItem] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let itemRepository: ReminderItemRepository
    private let roomRepository: RoomRepository
    
    // MARK: - Computed Properties
    
    var isEmpty: Bool {
        itemsByRoom.isEmpty && unassignedItems.isEmpty
    }
    
    var hasUnassignedItems: Bool {
        !unassignedItems.isEmpty
    }
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.itemRepository = ReminderItemRepository(context: context)
        self.roomRepository = RoomRepository(context: context)
        loadItems()
    }
    
    // MARK: - Public Methods
    
    func loadItems() {
        isLoading = true
        
        rooms = roomRepository.fetchAll()
        let allItems = itemRepository.fetchAll()
        var grouped: [(room: Room, items: [ReminderItem])] = []
        
        // 部屋ごとにグループ化
        for room in rooms {
            let roomItems = allItems.filter { $0.room?.objectID == room.objectID }
                .sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
            
            if !roomItems.isEmpty {
                grouped.append((room: room, items: roomItems))
            }
        }
        
        // 部屋未設定のアイテム
        unassignedItems = allItems.filter { $0.room == nil }
            .sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
        
        self.itemsByRoom = grouped
        isLoading = false
    }
    
    func completeItem(_ item: ReminderItem) {
        itemRepository.complete(item: item)
        loadItems()
    }
    
    func deleteItem(_ item: ReminderItem) {
        itemRepository.delete(item: item)
        loadItems()
    }
    
    func dueStatus(for item: ReminderItem) -> DueStatus {
        DueStatus.from(date: item.dueDate)
    }
}
