//
//  AppStrings.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation

/// アプリ全体で使用する文字列定数
/// ローカライズ対応を考慮した集中管理
struct AppStrings {
    
    // MARK: - App
    
    static let appName = "Wasurenai"
    
    // MARK: - Tab
    
    static let tabHome = "チェック"
    static let tabCalendar = "カレンダー"
    static let tabItems = "アイテム"
    static let tabSettings = "設定"
    
    // MARK: - Home
    
    static let homeTitle = "Wasurenai"
    static let homeEmpty = "登録されたアイテムがありません"
    static let homeEmptySubtitle = "アイテムタブから追加してください"
    static let homeDueToday = "今日"
    static let homeDueTomorrow = "明日"
    static let homeDueOverdue = "期限切れ"
    static let homeDueDaysFormat = "%d日後"
    static let homeDueOverdueFormat = "%d日超過"
    static let homeUpcoming = "もうすぐ"
    static let homeCompleted = "完了済み"
    static let homeSectionUrgent = "要対応"
    static let homeSectionOverdue = "期限切れ"
    static let homeSectionToday = "今日"
    static let homeSectionThisWeek = "今週"
    static let homeSectionLater = "今後"
    static let homeSectionByRoom = "部屋別"
    
    // MARK: - Items
    
    static let itemsTitle = "アイテム"
    static let itemsEmpty = "アイテムがありません"
    static let itemsEmptySubtitle = "＋ボタンからアイテムを追加しましょう"
    static let itemsSearchPlaceholder = "アイテムを検索"
    static let itemsAll = "すべて"
    
    // MARK: - Item Detail
    
    static let itemDetailTitle = "アイテム詳細"
    static let itemDetailName = "アイテム名"
    static let itemDetailNamePlaceholder = "例：ブルーレット置くだけ"
    static let itemDetailCategory = "カテゴリ"
    static let itemDetailCycle = "交換サイクル"
    static let itemDetailCycleUnit = "日ごと"
    static let itemDetailDueDate = "次回期日"
    static let itemDetailLastCompleted = "前回完了日"
    static let itemDetailNotify = "通知"
    static let itemDetailNotifyBefore = "日前に通知"
    static let itemDetailMemo = "メモ"
    static let itemDetailMemoPlaceholder = "メモを入力（任意）"
    static let itemDetailIcon = "アイコン"
    
    // MARK: - Settings
    
    static let settingsTitle = "設定"
    static let settingsCategoryManagement = "カテゴリ管理"
    static let settingsNotification = "通知設定"
    static let settingsNotificationEnable = "通知を有効にする"
    static let settingsNotificationTime = "通知時刻"
    static let settingsAbout = "このアプリについて"
    static let settingsVersion = "バージョン"
    static let settingsAppInfo = "アプリ情報"
    
    // MARK: - Category
    
    static let categoryTitle = "カテゴリ"
    static let categoryAdd = "カテゴリを追加"
    static let categoryEdit = "カテゴリを編集"
    static let categoryName = "カテゴリ名"
    static let categoryNamePlaceholder = "例：掃除用品"
    static let categoryColor = "カラー"
    static let categoryIcon = "アイコン"
    static let categoryEmpty = "カテゴリがありません"
    static let categoryNone = "カテゴリなし"
    
    // MARK: - Actions
    
    static let actionSave = "保存"
    static let actionCancel = "キャンセル"
    static let actionDelete = "削除"
    static let actionEdit = "編集"
    static let actionAdd = "追加"
    static let actionDone = "完了"
    static let actionComplete = "完了にする"
    static let actionReset = "リセット"
    static let actionClose = "閉じる"
    
    // MARK: - Alerts
    
    static let alertDeleteTitle = "削除の確認"
    static let alertDeleteItemMessage = "このアイテムを削除しますか？"
    static let alertDeleteCategoryMessage = "このカテゴリを削除しますか？カテゴリ内のアイテムも削除されます。"
    static let alertCompleteTitle = "完了確認"
    static let alertCompleteMessage = "このアイテムを完了にして、次回期日を更新しますか？"
    
    // MARK: - Preset Items
    
    static let presetBluelet = "ブルーレット置くだけ"
    static let presetKabikiller = "カビキラー"
    static let presetAirFreshener = "消臭力"
    static let presetWaterFilter = "浄水器カートリッジ"
    static let presetACFilter = "エアコンフィルター"
    static let presetToothbrush = "歯ブラシ"
    static let presetRazor = "カミソリ"
    static let presetContactLens = "コンタクトレンズ"
    
    // MARK: - Rooms
    
    static let roomsTitle = "部屋別"
    static let roomsEmpty = "アイテムがありません"
    static let roomsEmptySubtitle = "アイテムを追加すると部屋別に表示されます"
    
    // MARK: - History
    
    static let historyTitle = "完了履歴"
    static let historyEmpty = "まだ完了履歴がありません"
    static let historyEmptySubtitle = "アイテムを完了すると履歴が記録されます"
    static let historyClearAll = "すべて削除"
    static let historyClearMessage = "すべての完了履歴が削除されます。この操作は取り消せません。"
}
