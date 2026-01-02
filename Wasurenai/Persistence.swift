//
//  Persistence.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import CoreData

/// CoreDataの永続化コントローラー
struct PersistenceController {
    
    // MARK: - Shared Instance
    
    static let shared = PersistenceController()

    // MARK: - Preview Instance
    
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // プレビュー用のサンプルデータを作成
        createSampleData(in: viewContext)
        
        return result
    }()
    
    // MARK: - Properties

    let container: NSPersistentContainer

    // MARK: - Init
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Wasurenai")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 典型的なエラーの原因:
                 * 親ディレクトリが存在しない、作成できない、または書き込みが禁止されている
                 * デバイスがロックされている時にアクセス権限やデータ保護のために永続ストアにアクセスできない
                 * デバイスの空き容量が不足している
                 * 現在のモデルバージョンにストアを移行できなかった
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // 初期部屋を作成
        let context = container.viewContext
        Task { @MainActor in
            let roomRepository = RoomRepository(context: context)
            roomRepository.createDefaultRoomsIfNeeded()
        }
    }
    
    // MARK: - Sample Data
    
    @MainActor
    private static func createSampleData(in context: NSManagedObjectContext) {
        // サンプル部屋を作成
        let toiletRoom = Room(context: context)
        toiletRoom.id = UUID()
        toiletRoom.name = "トイレ"
        toiletRoom.colorHex = AppColors.categoryColors[0]
        toiletRoom.iconName = "toilet.fill"
        toiletRoom.sortOrder = 0
        toiletRoom.isDefault = true
        toiletRoom.createdAt = Date()
        
        let bathroomRoom = Room(context: context)
        bathroomRoom.id = UUID()
        bathroomRoom.name = "浴室"
        bathroomRoom.colorHex = AppColors.categoryColors[1]
        bathroomRoom.iconName = "bathtub.fill"
        bathroomRoom.sortOrder = 1
        bathroomRoom.isDefault = true
        bathroomRoom.createdAt = Date()
        
        let washroomRoom = Room(context: context)
        washroomRoom.id = UUID()
        washroomRoom.name = "洗面所"
        washroomRoom.colorHex = AppColors.categoryColors[4]
        washroomRoom.iconName = "sink.fill"
        washroomRoom.sortOrder = 2
        washroomRoom.isDefault = true
        washroomRoom.createdAt = Date()
        
        // サンプルアイテムを作成
        let items: [(name: String, room: Room, cycleDays: Int16, daysOffset: Int, icon: String)] = [
            ("ブルーレット置くだけ", toiletRoom, 30, -2, "drop.fill"),
            ("トイレスタンプ", toiletRoom, 14, 0, "sparkles"),
            ("カビキラー", bathroomRoom, 90, 5, "flame.fill"),
            ("お風呂の消臭力", bathroomRoom, 60, 10, "leaf.fill"),
            ("歯ブラシ", washroomRoom, 30, 3, "cross.case.fill"),
            ("コンタクトレンズ", washroomRoom, 14, 1, "eye"),
        ]
        
        for item in items {
            let reminderItem = ReminderItem(context: context)
            reminderItem.id = UUID()
            reminderItem.name = item.name
            reminderItem.room = item.room
            reminderItem.cycleDays = item.cycleDays
            reminderItem.dueDate = Date().adding(days: item.daysOffset)
            reminderItem.iconName = item.icon
            reminderItem.notifyBefore = 1
            reminderItem.isCompleted = false
            reminderItem.createdAt = Date()
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
