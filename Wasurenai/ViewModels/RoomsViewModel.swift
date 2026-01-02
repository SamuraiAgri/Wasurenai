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
    
    @Published var itemsByRoom: [(room: Room, items: [ReminderItem])] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let repository: ReminderItemRepository
    
    // MARK: - Computed Properties
    
    var isEmpty: Bool {
        itemsByRoom.isEmpty
    }
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.repository = ReminderItemRepository(context: context)
        loadItems()
    }
    
    // MARK: - Public Methods
    
    func loadItems() {
        isLoading = true
        
        let allItems = repository.fetchAll()
        var grouped: [(room: Room, items: [ReminderItem])] = []
        
        // 定義済みの部屋ごとにグループ化
        for room in RoomConstants.rooms {
            let roomItems = allItems.filter { $0.roomName == room.name }
                .sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
            
            if !roomItems.isEmpty {
                grouped.append((room: room, items: roomItems))
            }
        }
        
        // 部屋未設定のアイテム
        let unassignedItems = allItems.filter { item in
            guard let roomName = item.roomName, !roomName.isEmpty else { return true }
            return !RoomConstants.rooms.contains { $0.name == roomName }
        }.sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
        
        if !unassignedItems.isEmpty {
            let otherRoom = Room(name: "未設定", iconName: "questionmark.circle.fill")
            grouped.append((room: otherRoom, items: unassignedItems))
        }
        
        self.itemsByRoom = grouped
        isLoading = false
    }
    
    func completeItem(_ item: ReminderItem) {
        repository.complete(item: item)
        loadItems()
    }
    
    func deleteItem(_ item: ReminderItem) {
        repository.delete(item: item)
        loadItems()
    }
    
    func dueStatus(for item: ReminderItem) -> DueStatus {
        DueStatus.from(date: item.dueDate)
    }
}
