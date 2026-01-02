//
//  HistoryViewModel.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation
import CoreData
import Combine

/// 完了履歴画面のViewModel
@MainActor
final class HistoryViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var groupedHistories: [(month: Date, histories: [CompletionHistory])] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let repository: CompletionHistoryRepository
    
    // MARK: - Computed Properties
    
    var isEmpty: Bool {
        groupedHistories.isEmpty
    }
    
    var totalCount: Int {
        groupedHistories.reduce(0) { $0 + $1.histories.count }
    }
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.repository = CompletionHistoryRepository(context: context)
        loadHistories()
    }
    
    // MARK: - Public Methods
    
    func loadHistories() {
        isLoading = true
        groupedHistories = repository.fetchGroupedByMonth()
        isLoading = false
    }
    
    func deleteHistory(_ history: CompletionHistory) {
        repository.delete(history: history)
        loadHistories()
    }
    
    func clearAllHistories() {
        repository.deleteAll()
        loadHistories()
    }
    
    /// 月のフォーマット
    func monthString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: date)
    }
}
