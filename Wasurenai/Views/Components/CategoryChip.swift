//
//  CategoryChip.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// カテゴリを表示するチップコンポーネント
struct CategoryChip: View {
    
    let title: String
    let colorHex: String?
    let iconName: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 12, weight: .medium))
                }
                
                Text(title)
                    .font(AppFonts.captionBold)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected 
                    ? chipColor.opacity(0.2)
                    : AppColors.secondaryBackground
            )
            .foregroundColor(
                isSelected 
                    ? chipColor 
                    : AppColors.textSecondary
            )
            .cornerRadius(AppConstants.cornerRadiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadiusLarge)
                    .strokeBorder(
                        isSelected ? chipColor : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var chipColor: Color {
        if let hex = colorHex {
            return Color(hex: hex)
        }
        return AppColors.primary
    }
}

/// 「すべて」カテゴリ用のチップ
struct AllCategoryChip: View {
    
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        CategoryChip(
            title: AppStrings.itemsAll,
            colorHex: nil,
            iconName: "square.grid.2x2",
            isSelected: isSelected,
            action: action
        )
    }
}

#Preview {
    HStack {
        AllCategoryChip(isSelected: true) { }
        CategoryChip(
            title: "トイレ",
            colorHex: AppColors.categoryColors[0],
            iconName: "drop.fill",
            isSelected: false
        ) { }
        CategoryChip(
            title: "バスルーム",
            colorHex: AppColors.categoryColors[1],
            iconName: "bubbles.and.sparkles.fill",
            isSelected: false
        ) { }
    }
    .padding()
}
