//
//  RoomRepository.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData

/// Roomのデータ操作を担当するリポジトリ
final class RoomRepository: ObservableObject {
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // MARK: - Fetch
    
    /// すべての部屋を取得
    func fetchAll() -> [Room] {
        let request: NSFetchRequest<Room> = Room.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Room.sortOrder, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching rooms: \(error)")
            return []
        }
    }
    
    /// 部屋の数を取得
    func count() -> Int {
        let request: NSFetchRequest<Room> = Room.fetchRequest()
        
        do {
            return try viewContext.count(for: request)
        } catch {
            print("Error counting rooms: \(error)")
            return 0
        }
    }
    
    /// 名前で部屋を検索
    func findByName(_ name: String) -> Room? {
        let request: NSFetchRequest<Room> = Room.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error finding room by name: \(error)")
            return nil
        }
    }
    
    // MARK: - Create
    
    /// 新しい部屋を作成
    @discardableResult
    func create(
        name: String,
        colorHex: String,
        iconName: String,
        isDefault: Bool = false
    ) -> Room {
        let room = Room(context: viewContext)
        room.id = UUID()
        room.name = name
        room.colorHex = colorHex
        room.iconName = iconName
        room.isDefault = isDefault
        room.sortOrder = Int16(count())
        room.createdAt = Date()
        
        save()
        return room
    }
    
    // MARK: - Update
    
    /// 部屋を更新
    func update(
        room: Room,
        name: String,
        colorHex: String,
        iconName: String
    ) {
        room.name = name
        room.colorHex = colorHex
        room.iconName = iconName
        
        save()
    }
    
    /// 部屋の並び順を更新
    func updateSortOrder(rooms: [Room]) {
        for (index, room) in rooms.enumerated() {
            room.sortOrder = Int16(index)
        }
        save()
    }
    
    // MARK: - Delete
    
    /// 部屋を削除（デフォルトの部屋は削除不可）
    func delete(room: Room) {
        guard !room.isDefault else { return }
        viewContext.delete(room)
        save()
    }
    
    // MARK: - Default Rooms
    
    /// 初期部屋を作成
    func createDefaultRoomsIfNeeded() {
        guard count() == 0 else { return }
        
        let defaults: [(name: String, colorHex: String, iconName: String)] = [
            ("トイレ", AppColors.categoryColors[0], "toilet.fill"),
            ("浴室", AppColors.categoryColors[1], "bathtub.fill"),
            ("キッチン", AppColors.categoryColors[2], "refrigerator.fill"),
            ("リビング", AppColors.categoryColors[3], "sofa.fill"),
            ("洗面所", AppColors.categoryColors[4], "sink.fill"),
            ("寝室", AppColors.categoryColors[5], "bed.double.fill"),
            ("玄関", "#8E8E93", "door.left.hand.closed"),
            ("その他", "#AEAEB2", "ellipsis.circle.fill"),
        ]
        
        for (index, item) in defaults.enumerated() {
            let room = Room(context: viewContext)
            room.id = UUID()
            room.name = item.name
            room.colorHex = item.colorHex
            room.iconName = item.iconName
            room.isDefault = true
            room.sortOrder = Int16(index)
            room.createdAt = Date()
        }
        
        save()
    }
    
    // MARK: - Save
    
    /// 変更を保存
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
