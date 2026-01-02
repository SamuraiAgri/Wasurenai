//
//  Date+Extension.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import Foundation

extension Date {
    
    /// 今日の日付（時刻を除いた日付のみ）
    static var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    /// 日付のみを取得（時刻を0:00にリセット）
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// 指定した日数を加算した日付を返す
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// 今日からの日数差を計算
    var daysFromToday: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: self)
        let components = calendar.dateComponents([.day], from: today, to: target)
        return components.day ?? 0
    }
    
    /// 今日かどうか
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// 明日かどうか
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    /// 過去かどうか（今日より前）
    var isPast: Bool {
        self.startOfDay < Date.today
    }
    
    /// 今週かどうか（今日から7日以内）
    var isThisWeek: Bool {
        let days = daysFromToday
        return days >= 0 && days <= 7
    }
    
    /// 日付のフォーマット済み文字列を返す
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }
    
    /// 短い日付文字列（M/d形式）
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }
    
    /// 曜日を含む日付文字列
    var dateWithWeekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }
    
    /// 年月日の完全な文字列
    var fullDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }
}
