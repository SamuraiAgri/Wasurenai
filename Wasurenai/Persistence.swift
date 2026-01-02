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
        
        // 初期カテゴリを作成
        let context = container.viewContext
        Task { @MainActor in
            let categoryRepository = CategoryRepository(context: context)
            categoryRepository.createDefaultCategoriesIfNeeded()
        }
    }
    
    // MARK: - Sample Data
    
    @MainActor
    private static func createSampleData(in context: NSManagedObjectContext) {
        // サンプルカテゴリを作成
        let toiletCategory = Category(context: context)
        toiletCategory.id = UUID()
        toiletCategory.name = "トイレ"
        toiletCategory.colorHex = AppColors.categoryColors[0]
        toiletCategory.iconName = "drop.fill"
        toiletCategory.sortOrder = 0
        toiletCategory.createdAt = Date()
        
        let bathroomCategory = Category(context: context)
        bathroomCategory.id = UUID()
        bathroomCategory.name = "バスルーム"
        bathroomCategory.colorHex = AppColors.categoryColors[1]
        bathroomCategory.iconName = "bubbles.and.sparkles.fill"
        bathroomCategory.sortOrder = 1
        bathroomCategory.createdAt = Date()
        
        let healthCategory = Category(context: context)
        healthCategory.id = UUID()
        healthCategory.name = "健康・衛生"
        healthCategory.colorHex = AppColors.categoryColors[5]
        healthCategory.iconName = "cross.case.fill"
        healthCategory.sortOrder = 2
        healthCategory.createdAt = Date()
        
        // サンプルアイテムを作成
        let items: [(name: String, category: Category, cycleDays: Int16, daysOffset: Int, icon: String)] = [
            ("ブルーレット置くだけ", toiletCategory, 30, -2, "drop.fill"),
            ("トイレスタンプ", toiletCategory, 14, 0, "sparkles"),
            ("カビキラー", bathroomCategory, 90, 5, "flame.fill"),
            ("お風呂の消臭力", bathroomCategory, 60, 10, "leaf.fill"),
            ("歯ブラシ", healthCategory, 30, 3, "cross.case.fill"),
            ("コンタクトレンズ", healthCategory, 14, 1, "eye"),
        ]
        
        for item in items {
            let reminderItem = ReminderItem(context: context)
            reminderItem.id = UUID()
            reminderItem.name = item.name
            reminderItem.category = item.category
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
