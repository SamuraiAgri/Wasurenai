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
    let roomName: String
    
    // MARK: - Preset Data
    
    /// プリセット部屋ごとのアイテム
    static let presets: [PresetRoom] = [
        PresetRoom(
            name: "トイレ",
            iconName: "toilet.fill",
            items: [
                PresetItem(name: "ブルーレット置くだけ", iconName: "drop.fill", cycleDays: 30, roomName: "トイレ"),
                PresetItem(name: "トイレスタンプ", iconName: "sparkles", cycleDays: 14, roomName: "トイレ"),
                PresetItem(name: "トイレマジックリン", iconName: "bubbles.and.sparkles.fill", cycleDays: 60, roomName: "トイレ"),
                PresetItem(name: "トイレ消臭力", iconName: "leaf.fill", cycleDays: 60, roomName: "トイレ"),
            ]
        ),
        PresetRoom(
            name: "浴室",
            iconName: "bathtub.fill",
            items: [
                PresetItem(name: "カビキラー", iconName: "flame.fill", cycleDays: 90, roomName: "浴室"),
                PresetItem(name: "バスマジックリン", iconName: "bubbles.and.sparkles.fill", cycleDays: 60, roomName: "浴室"),
                PresetItem(name: "お風呂の消臭力", iconName: "leaf.fill", cycleDays: 60, roomName: "浴室"),
                PresetItem(name: "防カビくん煙剤", iconName: "aqi.medium", cycleDays: 60, roomName: "浴室"),
            ]
        ),
        PresetRoom(
            name: "キッチン",
            iconName: "refrigerator.fill",
            items: [
                PresetItem(name: "キッチンハイター", iconName: "flame.fill", cycleDays: 90, roomName: "キッチン"),
                PresetItem(name: "食器用洗剤", iconName: "bubbles.and.sparkles.fill", cycleDays: 30, roomName: "キッチン"),
                PresetItem(name: "スポンジ", iconName: "square.fill", cycleDays: 14, roomName: "キッチン"),
                PresetItem(name: "浄水器カートリッジ", iconName: "drop.fill", cycleDays: 90, roomName: "キッチン"),
                PresetItem(name: "排水口ネット", iconName: "line.3.horizontal.decrease.circle.fill", cycleDays: 7, roomName: "キッチン"),
            ]
        ),
        PresetRoom(
            name: "リビング",
            iconName: "sofa.fill",
            items: [
                PresetItem(name: "消臭力リビング用", iconName: "leaf.fill", cycleDays: 60, roomName: "リビング"),
                PresetItem(name: "エアコンフィルター", iconName: "fan.fill", cycleDays: 30, roomName: "リビング"),
                PresetItem(name: "空気清浄機フィルター", iconName: "aqi.medium", cycleDays: 180, roomName: "リビング"),
                PresetItem(name: "加湿器フィルター", iconName: "humidity.fill", cycleDays: 30, roomName: "リビング"),
            ]
        ),
        PresetRoom(
            name: "洗面所",
            iconName: "sink.fill",
            items: [
                PresetItem(name: "洗濯洗剤", iconName: "washer.fill", cycleDays: 30, roomName: "洗面所"),
                PresetItem(name: "柔軟剤", iconName: "wind", cycleDays: 30, roomName: "洗面所"),
                PresetItem(name: "洗濯槽クリーナー", iconName: "bubbles.and.sparkles.fill", cycleDays: 30, roomName: "洗面所"),
                PresetItem(name: "歯ブラシ", iconName: "cross.case.fill", cycleDays: 30, roomName: "洗面所"),
                PresetItem(name: "カミソリ", iconName: "scissors", cycleDays: 14, roomName: "洗面所"),
                PresetItem(name: "コンタクトレンズ", iconName: "eye", cycleDays: 30, roomName: "洗面所"),
                PresetItem(name: "ハンドソープ", iconName: "hand.raised.fill", cycleDays: 30, roomName: "洗面所"),
            ]
        ),
        PresetRoom(
            name: "寝室",
            iconName: "bed.double.fill",
            items: [
                PresetItem(name: "シーツ交換", iconName: "bed.double.fill", cycleDays: 14, roomName: "寝室"),
                PresetItem(name: "枕カバー交換", iconName: "pillow.fill", cycleDays: 7, roomName: "寝室"),
                PresetItem(name: "布団干し", iconName: "sun.max.fill", cycleDays: 14, roomName: "寝室"),
            ]
        ),
        PresetRoom(
            name: "その他",
            iconName: "ellipsis.circle.fill",
            items: [
                PresetItem(name: "常備薬チェック", iconName: "pills.fill", cycleDays: 180, roomName: "その他"),
                PresetItem(name: "防災グッズ点検", iconName: "cross.case.fill", cycleDays: 180, roomName: "その他"),
                PresetItem(name: "火災報知器点検", iconName: "flame.fill", cycleDays: 365, roomName: "その他"),
            ]
        ),
    ]
}

/// プリセット部屋
struct PresetRoom: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let items: [PresetItem]
}
