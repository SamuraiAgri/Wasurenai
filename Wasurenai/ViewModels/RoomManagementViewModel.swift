//
//  RoomManagementViewModel.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData
import Combine

/// 部屋管理画面のViewModel
@MainActor
final class RoomManagementViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var rooms: [Room] = []
    @Published var isLoading: Bool = false
    
    // 編集用
    @Published var editingRoom: Room? = nil
    @Published var editName: String = ""
    @Published var editIconName: String = "house.fill"
    @Published var editColorHex: String = AppColors.categoryColors[0]
    @Published var isShowingEditor: Bool = false
    
    // MARK: - Dependencies
    
    private let repository: RoomRepository
    
    // MARK: - Computed Properties
    
    var isEditing: Bool {
        editingRoom != nil
    }
    
    var canSave: Bool {
        !editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var editorTitle: String {
        isEditing ? "部屋を編集" : "部屋を追加"
    }
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.repository = RoomRepository(context: context)
        loadRooms()
    }
    
    // MARK: - Public Methods
    
    func loadRooms() {
        isLoading = true
        rooms = repository.fetchAll()
        isLoading = false
    }
    
    /// 新規追加モードを開始
    func startAdding() {
        editingRoom = nil
        editName = ""
        editIconName = "house.fill"
        editColorHex = AppColors.categoryColors[rooms.count % AppColors.categoryColors.count]
        isShowingEditor = true
    }
    
    /// 編集モードを開始
    func startEditing(room: Room) {
        editingRoom = room
        editName = room.name ?? ""
        editIconName = room.iconName ?? "house.fill"
        editColorHex = room.colorHex ?? AppColors.categoryColors[0]
        isShowingEditor = true
    }
    
    /// 保存
    func save() {
        guard canSave else { return }
        
        let trimmedName = editName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let room = editingRoom {
            repository.update(
                room: room,
                name: trimmedName,
                colorHex: editColorHex,
                iconName: editIconName
            )
        } else {
            repository.create(
                name: trimmedName,
                colorHex: editColorHex,
                iconName: editIconName
            )
        }
        
        isShowingEditor = false
        loadRooms()
    }
    
    /// 削除
    func delete(room: Room) {
        repository.delete(room: room)
        loadRooms()
    }
    
    /// 並べ替え
    func move(from source: IndexSet, to destination: Int) {
        var reorderedRooms = rooms
        reorderedRooms.move(fromOffsets: source, toOffset: destination)
        repository.updateSortOrder(rooms: reorderedRooms)
        loadRooms()
    }
    
    /// キャンセル
    func cancel() {
        isShowingEditor = false
        editingRoom = nil
    }
}
