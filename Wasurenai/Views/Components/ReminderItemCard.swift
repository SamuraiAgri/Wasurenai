//
//  ReminderItemCard.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// アイテムを表示するカードコンポーネント
struct ReminderItemCard: View {
    
    let item: ReminderItem
    let dueStatus: DueStatus
    let onComplete: () -> Void
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppConstants.paddingMedium) {
                // アイコン
                iconView
                
                // 情報
                VStack(alignment: .leading, spacing: 4) {
                    // アイテム名
                    Text(item.name ?? "")
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    // カテゴリ
                    if let category = item.category {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: category.colorHex ?? AppColors.categoryColors[0]))
                                .frame(width: 8, height: 8)
                            Text(category.name ?? "")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // 期日情報
                VStack(alignment: .trailing, spacing: 4) {
                    // ステータステキスト
                    Text(dueStatus.displayText)
                        .font(AppFonts.captionBold)
                        .foregroundColor(dueStatus.color)
                    
                    // 日付
                    if let dueDate = item.dueDate {
                        Text(dueDate.shortDateString)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // 完了ボタン
                completeButton
            }
            .padding(AppConstants.paddingMedium)
            .background(AppColors.cardBackground)
            .cornerRadius(AppConstants.cornerRadiusMedium)
            .shadow(
                color: dueStatus.priority <= 1 ? dueStatus.color.opacity(0.2) : Color.black.opacity(AppConstants.shadowOpacity),
                radius: AppConstants.shadowRadius,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
    }
    
    // MARK: - Subviews
    
    private var iconView: some View {
        ZStack {
            Circle()
                .fill(dueStatus.color.opacity(0.15))
                .frame(width: 48, height: 48)
            
            Image(systemName: item.iconName ?? AppIcons.itemIcons[0])
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(dueStatus.color)
        }
    }
    
    private var completeButton: some View {
        Button(action: {
            withAnimation(AppConstants.springAnimation) {
                onComplete()
            }
        }) {
            Image(systemName: AppIcons.checkCircle)
                .font(.system(size: 28))
                .foregroundColor(AppColors.success)
                .opacity(0.8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 16) {
        // プレビュー用のモックデータが必要
        Text("Preview requires CoreData context")
            .foregroundColor(.secondary)
    }
    .padding()
    .background(AppColors.background)
}
