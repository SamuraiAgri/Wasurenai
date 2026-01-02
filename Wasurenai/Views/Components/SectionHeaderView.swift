//
//  SectionHeaderView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// セクションヘッダービュー
struct SectionHeaderView: View {
    
    let title: String
    let iconName: String?
    let color: Color
    let count: Int?
    
    init(
        title: String,
        iconName: String? = nil,
        color: Color = AppColors.textSecondary,
        count: Int? = nil
    ) {
        self.title = title
        self.iconName = iconName
        self.color = color
        self.count = count
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(AppFonts.subheadlineBold)
                .foregroundColor(color)
            
            if let count = count, count > 0 {
                Text("\(count)")
                    .font(AppFonts.badge)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(color)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding(.horizontal, AppConstants.paddingMedium)
        .padding(.vertical, AppConstants.paddingSmall)
    }
}

#Preview {
    VStack(spacing: 0) {
        SectionHeaderView(
            title: "期限切れ",
            iconName: AppIcons.warning,
            color: AppColors.danger,
            count: 3
        )
        SectionHeaderView(
            title: "今日",
            iconName: AppIcons.upcoming,
            color: AppColors.warning,
            count: 2
        )
        SectionHeaderView(
            title: "今週",
            iconName: AppIcons.calendar,
            color: AppColors.primary
        )
    }
}
