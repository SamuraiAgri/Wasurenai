//
//  CategoryViewModel.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData

/// カテゴリ管理画面のViewModel
@MainActor
final class CategoryViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let repository: CategoryRepository
    
    // MARK: - Computed Properties
    
    var isEmpty: Bool {
        categories.isEmpty
    }
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.repository = CategoryRepository(context: context)
        loadCategories()
    }
    
    // MARK: - Public Methods
    
    /// カテゴリを読み込む
    func loadCategories() {
        isLoading = true
        categories = repository.fetchAll()
        isLoading = false
    }
    
    /// カテゴリを削除
    func deleteCategory(_ category: Category) {
        repository.delete(category: category)
        loadCategories()
    }
    
    /// カテゴリの並び順を更新
    func moveCategory(from source: IndexSet, to destination: Int) {
        var updatedCategories = categories
        updatedCategories.move(fromOffsets: source, toOffset: destination)
        repository.updateSortOrder(categories: updatedCategories)
        loadCategories()
    }
}
