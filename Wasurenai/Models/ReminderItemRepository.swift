//
//  ReminderItemRepository.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData

/// ReminderItemのデータ操作を担当するリポジトリ
final class ReminderItemRepository: ObservableObject {
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // MARK: - Fetch
    
    /// すべてのアイテムを取得
    func fetchAll() -> [ReminderItem] {
        let request: NSFetchRequest<ReminderItem> = ReminderItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ReminderItem.dueDate, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching items: \(error)")
            return []
        }
    }
    
    /// 部屋でフィルタしてアイテムを取得
    func fetchByRoom(_ room: Room?) -> [ReminderItem] {
        let request: NSFetchRequest<ReminderItem> = ReminderItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ReminderItem.dueDate, ascending: true)]
        
        if let room = room {
            request.predicate = NSPredicate(format: "room == %@", room)
        }
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching items by room: \(error)")
            return []
        }
    }
    
    /// 期日が近いアイテムを取得（指定日数以内）
    func fetchUpcoming(days: Int = 7) -> [ReminderItem] {
        let request: NSFetchRequest<ReminderItem> = ReminderItem.fetchRequest()
        let today = Date.today
        let endDate = today.adding(days: days)
        
        request.predicate = NSPredicate(format: "dueDate >= %@ AND dueDate <= %@", today as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ReminderItem.dueDate, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching upcoming items: \(error)")
            return []
        }
    }
    
    /// 期限切れのアイテムを取得
    func fetchOverdue() -> [ReminderItem] {
        let request: NSFetchRequest<ReminderItem> = ReminderItem.fetchRequest()
        let today = Date.today
        
        request.predicate = NSPredicate(format: "dueDate < %@", today as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ReminderItem.dueDate, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching overdue items: \(error)")
            return []
        }
    }
    
    // MARK: - Create
    
    /// 新しいアイテムを作成
    @discardableResult
    func create(
        name: String,
        room: Room?,
        cycleDays: Int16,
        dueDate: Date,
        iconName: String?,
        memo: String?,
        notifyBefore: Int16
    ) -> ReminderItem {
        let item = ReminderItem(context: viewContext)
        item.id = UUID()
        item.name = name
        item.room = room
        item.cycleDays = cycleDays
        item.dueDate = dueDate
        item.iconName = iconName
        item.memo = memo
        item.notifyBefore = notifyBefore
        item.isCompleted = false
        item.createdAt = Date()
        
        save()
        return item
    }
    
    // MARK: - Update
    
    /// アイテムを更新
    func update(
        item: ReminderItem,
        name: String,
        room: Room?,
        cycleDays: Int16,
        dueDate: Date,
        iconName: String?,
        memo: String?,
        notifyBefore: Int16
    ) {
        item.name = name
        item.room = room
        item.cycleDays = cycleDays
        item.dueDate = dueDate
        item.iconName = iconName
        item.memo = memo
        item.notifyBefore = notifyBefore
        
        save()
    }
    
    /// アイテムを完了にして次回期日を更新（履歴も記録）
    func complete(item: ReminderItem, note: String? = nil) {
        // 完了履歴を作成
        let historyRepo = CompletionHistoryRepository(context: viewContext)
        historyRepo.create(item: item, note: note)
        
        // 次回期日を更新
        item.lastCompletedAt = Date()
        item.dueDate = Date().adding(days: Int(item.cycleDays))
        item.isCompleted = false // 次のサイクルに向けてリセット
        
        save()
    }
    
    // MARK: - Delete
    
    /// アイテムを削除
    func delete(item: ReminderItem) {
        viewContext.delete(item)
        save()
    }
    
    /// 複数のアイテムを削除
    func delete(items: [ReminderItem]) {
        items.forEach { viewContext.delete($0) }
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
