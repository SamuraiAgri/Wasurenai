//
//  WasurenaiWidget.swift
//  WasurenaiWidget
//
//  Created by rinka on 2026/01/02.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct ReminderEntry: TimelineEntry {
    let date: Date
    let items: [WidgetReminderItem]
    let hasUrgent: Bool
}

struct WidgetReminderItem: Identifiable {
    let id: UUID
    let name: String
    let iconName: String
    let categoryName: String?
    let categoryColor: String?
    let dueDate: Date?
    let dueStatus: WidgetDueStatus
}

enum WidgetDueStatus {
    case overdue
    case today
    case tomorrow
    case upcoming
    case later
    
    var displayText: String {
        switch self {
        case .overdue: return "期限切れ"
        case .today: return "今日"
        case .tomorrow: return "明日"
        case .upcoming: return "もうすぐ"
        case .later: return "今後"
        }
    }
    
    var color: Color {
        switch self {
        case .overdue: return .red
        case .today: return .orange
        case .tomorrow: return .yellow
        case .upcoming: return .blue
        case .later: return .gray
        }
    }
    
    static func from(date: Date?) -> WidgetDueStatus {
        guard let date = date else { return .later }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDay = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: today, to: targetDay).day ?? 0
        
        if days < 0 { return .overdue }
        if days == 0 { return .today }
        if days == 1 { return .tomorrow }
        if days <= 7 { return .upcoming }
        return .later
    }
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> ReminderEntry {
        ReminderEntry(
            date: Date(),
            items: [
                WidgetReminderItem(
                    id: UUID(),
                    name: "ブルーレット置くだけ",
                    iconName: "drop.fill",
                    categoryName: "トイレ",
                    categoryColor: "#4ECDC4",
                    dueDate: Date(),
                    dueStatus: .today
                )
            ],
            hasUrgent: true
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ReminderEntry) -> Void) {
        let entry = ReminderEntry(
            date: Date(),
            items: fetchItems(),
            hasUrgent: true
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ReminderEntry>) -> Void) {
        let items = fetchItems()
        let hasUrgent = items.contains { 
            $0.dueStatus == .overdue || $0.dueStatus == .today || $0.dueStatus == .tomorrow 
        }
        
        let entry = ReminderEntry(
            date: Date(),
            items: items,
            hasUrgent: hasUrgent
        )
        
        // 1時間ごとに更新
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func fetchItems() -> [WidgetReminderItem] {
        // App Groupを使用してデータを共有する場合はここで実装
        // 現在はサンプルデータを返す
        return [
            WidgetReminderItem(
                id: UUID(),
                name: "ブルーレット置くだけ",
                iconName: "drop.fill",
                categoryName: "トイレ",
                categoryColor: "#4ECDC4",
                dueDate: Date(),
                dueStatus: .today
            ),
            WidgetReminderItem(
                id: UUID(),
                name: "カビキラー",
                iconName: "flame.fill",
                categoryName: "バスルーム",
                categoryColor: "#FF6B6B",
                dueDate: Date().addingTimeInterval(86400),
                dueStatus: .tomorrow
            ),
            WidgetReminderItem(
                id: UUID(),
                name: "歯ブラシ",
                iconName: "cross.case.fill",
                categoryName: "健康・衛生",
                categoryColor: "#95E1D3",
                dueDate: Date().addingTimeInterval(172800),
                dueStatus: .upcoming
            )
        ]
    }
}

// MARK: - Widget Views

struct WasurenaiWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: ReminderEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ヘッダー
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.teal)
                Text("Wasurenai")
                    .font(.caption.bold())
                    .foregroundColor(.primary)
                Spacer()
            }
            
            if entry.items.isEmpty {
                Spacer()
                Text("期限間近の\nアイテムなし")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else if let item = entry.items.first {
                Spacer()
                
                // アイコン
                HStack {
                    Image(systemName: item.iconName)
                        .font(.title2)
                        .foregroundColor(item.dueStatus.color)
                    Spacer()
                }
                
                // アイテム名
                Text(item.name)
                    .font(.subheadline.bold())
                    .lineLimit(2)
                
                // ステータス
                Text(item.dueStatus.displayText)
                    .font(.caption.bold())
                    .foregroundColor(item.dueStatus.color)
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: ReminderEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ヘッダー
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.teal)
                Text("Wasurenai")
                    .font(.caption.bold())
                
                Spacer()
                
                if entry.hasUrgent {
                    Text("\(entry.items.count)件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if entry.items.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("期限間近のアイテムはありません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Spacer()
            } else {
                HStack(spacing: 12) {
                    ForEach(entry.items.prefix(3)) { item in
                        itemCard(item)
                    }
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
    
    private func itemCard(_ item: WidgetReminderItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // アイコン
            ZStack {
                Circle()
                    .fill(item.dueStatus.color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: item.iconName)
                    .font(.system(size: 14))
                    .foregroundColor(item.dueStatus.color)
            }
            
            // 名前
            Text(item.name)
                .font(.caption2.bold())
                .lineLimit(2)
            
            // ステータス
            Text(item.dueStatus.displayText)
                .font(.caption2)
                .foregroundColor(item.dueStatus.color)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: ReminderEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.teal)
                Text("Wasurenai")
                    .font(.headline)
                
                Spacer()
                
                Text("\(entry.items.count)件の期限間近")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            if entry.items.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                        Text("すべて完了！")
                            .font(.headline)
                    }
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(entry.items.prefix(5)) { item in
                    itemRow(item)
                    if item.id != entry.items.prefix(5).last?.id {
                        Divider()
                    }
                }
                Spacer()
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
    
    private func itemRow(_ item: WidgetReminderItem) -> some View {
        HStack(spacing: 12) {
            // アイコン
            ZStack {
                Circle()
                    .fill(item.dueStatus.color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: item.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(item.dueStatus.color)
            }
            
            // 情報
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                
                if let category = item.categoryName {
                    Text(category)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // ステータス
            VStack(alignment: .trailing, spacing: 2) {
                Text(item.dueStatus.displayText)
                    .font(.caption.bold())
                    .foregroundColor(item.dueStatus.color)
                
                if let date = item.dueDate {
                    Text(formatDate(date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

// MARK: - Widget Configuration

struct WasurenaiWidget: Widget {
    let kind: String = "WasurenaiWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WasurenaiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Wasurenai")
        .description("期限間近のアイテムを表示します")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    WasurenaiWidget()
} timeline: {
    ReminderEntry(
        date: Date(),
        items: [
            WidgetReminderItem(
                id: UUID(),
                name: "ブルーレット置くだけ",
                iconName: "drop.fill",
                categoryName: "トイレ",
                categoryColor: "#4ECDC4",
                dueDate: Date(),
                dueStatus: .today
            )
        ],
        hasUrgent: true
    )
}
