//
//  WasurenaiApp.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

@main
struct WasurenaiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
