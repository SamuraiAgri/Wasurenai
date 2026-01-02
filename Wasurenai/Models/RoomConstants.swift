//
//  RoomConstants.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation

/// 部屋の定数
struct RoomConstants {
    
    /// 定義済みの部屋リスト
    static let rooms: [Room] = [
        Room(name: "トイレ", iconName: "toilet.fill"),
        Room(name: "浴室", iconName: "bathtub.fill"),
        Room(name: "キッチン", iconName: "refrigerator.fill"),
        Room(name: "リビング", iconName: "lamp.desk.fill"),
        Room(name: "洗面所", iconName: "sink.fill"),
        Room(name: "寝室", iconName: "bed.double.fill"),
        Room(name: "玄関", iconName: "door.left.hand.closed"),
        Room(name: "その他", iconName: "ellipsis.circle.fill"),
    ]
    
    /// 部屋名から部屋を取得
    static func room(for name: String?) -> Room? {
        guard let name = name else { return nil }
        return rooms.first { $0.name == name }
    }
}

/// 部屋モデル
struct Room: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let iconName: String
}
