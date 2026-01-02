//
//  CategoryRepository.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData

/// Categoryのデータ操作を担当するリポジトリ
final class CategoryRepository: ObservableObject {
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // MARK: - Fetch
    
    /// すべてのカテゴリを取得
    func fetchAll() -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    /// カテゴリの数を取得
    func count() -> Int {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            return try viewContext.count(for: request)
        } catch {
            print("Error counting categories: \(error)")
            return 0
        }
    }
    
    // MARK: - Create
    
    /// 新しいカテゴリを作成
    @discardableResult
    func create(
        name: String,
        colorHex: String,
        iconName: String
    ) -> Category {
        let category = Category(context: viewContext)
        category.id = UUID()
        category.name = name
        category.colorHex = colorHex
        category.iconName = iconName
        category.sortOrder = Int16(count())
        category.createdAt = Date()
        
        save()
        return category
    }
    
    // MARK: - Update
    
    /// カテゴリを更新
    func update(
        category: Category,
        name: String,
        colorHex: String,
        iconName: String
    ) {
        category.name = name
        category.colorHex = colorHex
        category.iconName = iconName
        
        save()
    }
    
    /// カテゴリの並び順を更新
    func updateSortOrder(categories: [Category]) {
        for (index, category) in categories.enumerated() {
            category.sortOrder = Int16(index)
        }
        save()
    }
    
    // MARK: - Delete
    
    /// カテゴリを削除（関連するアイテムも削除される）
    func delete(category: Category) {
        viewContext.delete(category)
        save()
    }
    
    // MARK: - Default Categories
    
    /// 初期カテゴリを作成
    func createDefaultCategoriesIfNeeded() {
        guard count() == 0 else { return }
        
        let defaults: [(name: String, colorHex: String, iconName: String)] = [
            ("トイレ", AppColors.categoryColors[0], "drop.fill"),
            ("バスルーム", AppColors.categoryColors[1], "bubbles.and.sparkles.fill"),
            ("キッチン", AppColors.categoryColors[2], "refrigerator.fill"),
            ("リビング", AppColors.categoryColors[3], "lamp.desk.fill"),
            ("洗濯", AppColors.categoryColors[4], "washer.fill"),
            ("健康・衛生", AppColors.categoryColors[5], "cross.case.fill"),
        ]
        
        for (index, item) in defaults.enumerated() {
            let category = Category(context: viewContext)
            category.id = UUID()
            category.name = item.name
            category.colorHex = item.colorHex
            category.iconName = item.iconName
            category.sortOrder = Int16(index)
            category.createdAt = Date()
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
