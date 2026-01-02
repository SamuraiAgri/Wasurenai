//
//  CompletionHistoryRepository.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData

/// CompletionHistoryのデータ操作を担当するリポジトリ
final class CompletionHistoryRepository: ObservableObject {
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // MARK: - Fetch
    
    /// すべての完了履歴を取得（新しい順）
    func fetchAll() -> [CompletionHistory] {
        let request: NSFetchRequest<CompletionHistory> = CompletionHistory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CompletionHistory.completedAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching completion histories: \(error)")
            return []
        }
    }
    
    /// 指定した日数分の完了履歴を取得
    func fetchRecent(days: Int = 30) -> [CompletionHistory] {
        let request: NSFetchRequest<CompletionHistory> = CompletionHistory.fetchRequest()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        request.predicate = NSPredicate(format: "completedAt >= %@", startDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CompletionHistory.completedAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching recent histories: \(error)")
            return []
        }
    }
    
    /// 特定のアイテムの完了履歴を取得
    func fetchByItem(_ item: ReminderItem) -> [CompletionHistory] {
        let request: NSFetchRequest<CompletionHistory> = CompletionHistory.fetchRequest()
        request.predicate = NSPredicate(format: "item == %@", item)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CompletionHistory.completedAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching item histories: \(error)")
            return []
        }
    }
    
    /// 月別にグループ化した完了履歴を取得
    func fetchGroupedByMonth() -> [(month: Date, histories: [CompletionHistory])] {
        let allHistories = fetchAll()
        let calendar = Calendar.current
        
        var grouped: [Date: [CompletionHistory]] = [:]
        
        for history in allHistories {
            guard let date = history.completedAt else { continue }
            let components = calendar.dateComponents([.year, .month], from: date)
            guard let monthStart = calendar.date(from: components) else { continue }
            
            if grouped[monthStart] == nil {
                grouped[monthStart] = []
            }
            grouped[monthStart]?.append(history)
        }
        
        return grouped
            .map { (month: $0.key, histories: $0.value) }
            .sorted { $0.month > $1.month }
    }
    
    // MARK: - Create
    
    /// 完了履歴を作成
    @discardableResult
    func create(item: ReminderItem, note: String? = nil) -> CompletionHistory {
        let history = CompletionHistory(context: viewContext)
        history.id = UUID()
        history.item = item
        history.itemName = item.name // アイテム削除後も名前を保持
        history.completedAt = Date()
        history.note = note
        
        save()
        return history
    }
    
    // MARK: - Delete
    
    /// 完了履歴を削除
    func delete(history: CompletionHistory) {
        viewContext.delete(history)
        save()
    }
    
    /// すべての完了履歴を削除
    func deleteAll() {
        let request: NSFetchRequest<NSFetchRequestResult> = CompletionHistory.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try viewContext.execute(deleteRequest)
            save()
        } catch {
            print("Error deleting all histories: \(error)")
        }
    }
    
    // MARK: - Save
    
    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
