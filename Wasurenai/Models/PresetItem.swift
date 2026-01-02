//
//  PresetItem.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation

/// プリセットアイテムのモデル
struct PresetItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let iconName: String
    let cycleDays: Int
    let categoryName: String
    let roomName: String
    
    // MARK: - Preset Data
    
    /// プリセットカテゴリごとのアイテム
    static let presets: [PresetCategory] = [
        PresetCategory(
            name: "トイレ",
            room: "トイレ",
            items: [
                PresetItem(name: "ブルーレット置くだけ", iconName: "drop.fill", cycleDays: 30, categoryName: "トイレ", roomName: "トイレ"),
                PresetItem(name: "トイレスタンプ", iconName: "sparkles", cycleDays: 14, categoryName: "トイレ", roomName: "トイレ"),
                PresetItem(name: "トイレマジックリン", iconName: "bubbles.and.sparkles.fill", cycleDays: 60, categoryName: "トイレ", roomName: "トイレ"),
                PresetItem(name: "トイレ消臭力", iconName: "leaf.fill", cycleDays: 60, categoryName: "トイレ", roomName: "トイレ"),
            ]
        ),
        PresetCategory(
            name: "バスルーム",
            room: "浴室",
            items: [
                PresetItem(name: "カビキラー", iconName: "flame.fill", cycleDays: 90, categoryName: "バスルーム", roomName: "浴室"),
                PresetItem(name: "バスマジックリン", iconName: "bubbles.and.sparkles.fill", cycleDays: 60, categoryName: "バスルーム", roomName: "浴室"),
                PresetItem(name: "お風呂の消臭力", iconName: "leaf.fill", cycleDays: 60, categoryName: "バスルーム", roomName: "浴室"),
                PresetItem(name: "防カビくん煙剤", iconName: "aqi.medium", cycleDays: 60, categoryName: "バスルーム", roomName: "浴室"),
            ]
        ),
        PresetCategory(
            name: "キッチン",
            room: "キッチン",
            items: [
                PresetItem(name: "キッチンハイター", iconName: "flame.fill", cycleDays: 90, categoryName: "キッチン", roomName: "キッチン"),
                PresetItem(name: "食器用洗剤", iconName: "bubbles.and.sparkles.fill", cycleDays: 30, categoryName: "キッチン", roomName: "キッチン"),
                PresetItem(name: "スポンジ", iconName: "square.fill", cycleDays: 14, categoryName: "キッチン", roomName: "キッチン"),
                PresetItem(name: "浄水器カートリッジ", iconName: "drop.fill", cycleDays: 90, categoryName: "キッチン", roomName: "キッチン"),
                PresetItem(name: "排水口ネット", iconName: "line.3.horizontal.decrease.circle.fill", cycleDays: 7, categoryName: "キッチン", roomName: "キッチン"),
            ]
        ),
        PresetCategory(
            name: "リビング",
            room: "リビング",
            items: [
                PresetItem(name: "消臭力リビング用", iconName: "leaf.fill", cycleDays: 60, categoryName: "リビング", roomName: "リビング"),
                PresetItem(name: "エアコンフィルター", iconName: "fan.fill", cycleDays: 30, categoryName: "リビング", roomName: "リビング"),
                PresetItem(name: "空気清浄機フィルター", iconName: "aqi.medium", cycleDays: 180, categoryName: "リビング", roomName: "リビング"),
                PresetItem(name: "加湿器フィルター", iconName: "humidity.fill", cycleDays: 30, categoryName: "リビング", roomName: "リビング"),
            ]
        ),
        PresetCategory(
            name: "洗濯",
            room: "洗面所",
            items: [
                PresetItem(name: "洗濯洗剤", iconName: "washer.fill", cycleDays: 30, categoryName: "洗濯", roomName: "洗面所"),
                PresetItem(name: "柔軟剤", iconName: "wind", cycleDays: 30, categoryName: "洗濯", roomName: "洗面所"),
                PresetItem(name: "洗濯槽クリーナー", iconName: "bubbles.and.sparkles.fill", cycleDays: 30, categoryName: "洗濯", roomName: "洗面所"),
            ]
        ),
        PresetCategory(
            name: "健康・衛生",
            room: "洗面所",
            items: [
                PresetItem(name: "歯ブラシ", iconName: "cross.case.fill", cycleDays: 30, categoryName: "健康・衛生", roomName: "洗面所"),
                PresetItem(name: "カミソリ", iconName: "scissors", cycleDays: 14, categoryName: "健康・衛生", roomName: "洗面所"),
                PresetItem(name: "コンタクトレンズ", iconName: "eye", cycleDays: 30, categoryName: "健康・衛生", roomName: "洗面所"),
                PresetItem(name: "常備薬", iconName: "pills.fill", cycleDays: 180, categoryName: "健康・衛生", roomName: "洗面所"),
                PresetItem(name: "ハンドソープ", iconName: "hand.raised.fill", cycleDays: 30, categoryName: "健康・衛生", roomName: "洗面所"),
            ]
        ),
    ]
}

/// プリセットカテゴリ
struct PresetCategory: Identifiable {
    let id = UUID()
    let name: String
    let room: String
    let items: [PresetItem]
}
