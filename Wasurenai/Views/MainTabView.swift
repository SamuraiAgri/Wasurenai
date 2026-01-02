//
//  MainTabView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// メインのタブビュー
struct MainTabView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: Tab = .home
    
    enum Tab: Int, CaseIterable {
        case home
        case calendar
        case items
        case rooms
        case settings
        
        var title: String {
            switch self {
            case .home: return AppStrings.tabHome
            case .calendar: return AppStrings.tabCalendar
            case .items: return AppStrings.tabItems
            case .rooms: return "部屋別"
            case .settings: return AppStrings.tabSettings
            }
        }
        
        var iconName: String {
            switch self {
            case .home: return AppIcons.tabHomeOutline
            case .calendar: return AppIcons.tabCalendarOutline
            case .items: return AppIcons.tabItemsOutline
            case .rooms: return "location"
            case .settings: return AppIcons.tabSettingsOutline
            }
        }
        
        var selectedIconName: String {
            switch self {
            case .home: return AppIcons.tabHome
            case .calendar: return AppIcons.tabCalendar
            case .items: return AppIcons.tabItems
            case .rooms: return "location.fill"
            case .settings: return AppIcons.tabSettings
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label(
                        Tab.home.title,
                        systemImage: selectedTab == .home ? Tab.home.selectedIconName : Tab.home.iconName
                    )
                }
                .tag(Tab.home)
            
            CalendarView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label(
                        Tab.calendar.title,
                        systemImage: selectedTab == .calendar ? Tab.calendar.selectedIconName : Tab.calendar.iconName
                    )
                }
                .tag(Tab.calendar)
            
            ItemsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label(
                        Tab.items.title,
                        systemImage: selectedTab == .items ? Tab.items.selectedIconName : Tab.items.iconName
                    )
                }
                .tag(Tab.items)
            
            RoomsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label(
                        Tab.rooms.title,
                        systemImage: selectedTab == .rooms ? Tab.rooms.selectedIconName : Tab.rooms.iconName
                    )
                }
                .tag(Tab.rooms)
            
            SettingsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label(
                        Tab.settings.title,
                        systemImage: selectedTab == .settings ? Tab.settings.selectedIconName : Tab.settings.iconName
                    )
                }
                .tag(Tab.settings)
        }
        .tint(AppColors.primary)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
