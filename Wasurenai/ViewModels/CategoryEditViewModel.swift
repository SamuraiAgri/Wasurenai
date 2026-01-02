//
//  CategoryEditViewModel.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData

/// カテゴリ編集画面のViewModel
@MainActor
final class CategoryEditViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var name: String = ""
    @Published var selectedColorHex: String = AppColors.categoryColors[0]
    @Published var selectedIconName: String = AppIcons.categoryIcons[0]
    @Published var isSaving: Bool = false
    
    // MARK: - Properties
    
    private let repository: CategoryRepository
    private let editingCategory: Category?
    
    /// 編集モードかどうか
    var isEditing: Bool {
        editingCategory != nil
    }
    
    /// 保存可能かどうか
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 画面タイトル
    var title: String {
        isEditing ? AppStrings.categoryEdit : AppStrings.categoryAdd
    }
    
    // MARK: - Init
    
    /// 新規作成用
    init(context: NSManagedObjectContext) {
        self.repository = CategoryRepository(context: context)
        self.editingCategory = nil
    }
    
    /// 編集用
    init(context: NSManagedObjectContext, category: Category) {
        self.repository = CategoryRepository(context: context)
        self.editingCategory = category
        
        loadCategoryData(category)
    }
    
    // MARK: - Private Methods
    
    private func loadCategoryData(_ category: Category) {
        name = category.name ?? ""
        selectedColorHex = category.colorHex ?? AppColors.categoryColors[0]
        selectedIconName = category.iconName ?? AppIcons.categoryIcons[0]
    }
    
    // MARK: - Public Methods
    
    /// カテゴリを保存
    func save() {
        guard canSave else { return }
        
        isSaving = true
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let category = editingCategory {
            repository.update(
                category: category,
                name: trimmedName,
                colorHex: selectedColorHex,
                iconName: selectedIconName
            )
        } else {
            repository.create(
                name: trimmedName,
                colorHex: selectedColorHex,
                iconName: selectedIconName
            )
        }
        
        isSaving = false
    }
    
    /// カテゴリを削除
    func delete() {
        guard let category = editingCategory else { return }
        repository.delete(category: category)
    }
}
