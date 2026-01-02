//
//  WasurenaiApp.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

@main
struct WasurenaiApp: App {
    
    // MARK: - Properties
    
    let persistenceController = PersistenceController.shared
    
    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
