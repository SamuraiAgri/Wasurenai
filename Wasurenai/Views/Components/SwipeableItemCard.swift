//
//  SwipeableItemCard.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// スワイプ可能なアイテムカード
struct SwipeableItemCard: View {
    
    let item: ReminderItem
    let dueStatus: DueStatus
    let onComplete: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    
    private let swipeThreshold: CGFloat = 60
    private let maxOffset: CGFloat = 160
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // 背景のアクションボタン
            HStack(spacing: 0) {
                Spacer()
                
                // 編集ボタン
                Button {
                    hapticFeedback.impactOccurred()
                    resetOffset()
                    onEdit()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: AppIcons.edit)
                            .font(.system(size: 20))
                        Text("編集")
                            .font(AppFonts.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(AppColors.primary)
                }
                
                // 完了ボタン
                Button {
                    hapticFeedback.impactOccurred()
                    resetOffset()
                    onComplete()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: AppIcons.checkCircle)
                            .font(.system(size: 20))
                        Text("完了")
                            .font(AppFonts.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(AppColors.success)
                }
            }
            .cornerRadius(AppConstants.cornerRadiusMedium)
            
            // メインカード
            itemCardContent
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let translation = value.translation.width
                            if translation < 0 {
                                // 左スワイプのみ許可
                                offset = max(translation, -maxOffset)
                            } else if isSwiped {
                                // 戻るスワイプ
                                offset = min(-maxOffset + translation, 0)
                            }
                        }
                        .onEnded { value in
                            withAnimation(AppConstants.springAnimation) {
                                if offset < -swipeThreshold {
                                    offset = -maxOffset
                                    isSwiped = true
                                    hapticFeedback.impactOccurred()
                                } else {
                                    offset = 0
                                    isSwiped = false
                                }
                            }
                        }
                )
                .animation(AppConstants.springAnimation, value: offset)
        }
        .clipped()
    }
    
    private var itemCardContent: some View {
        HStack(spacing: AppConstants.paddingMedium) {
            // アイコン
            ZStack {
                Circle()
                    .fill(dueStatus.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: item.iconName ?? AppIcons.itemIcons[0])
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(dueStatus.color)
            }
            
            // 情報
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name ?? "")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    if let room = item.room {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: room.colorHex ?? AppColors.categoryColors[0]))
                                .frame(width: 8, height: 8)
                            Text(room.name ?? "")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // 期日情報
            VStack(alignment: .trailing, spacing: 4) {
                Text(dueStatus.displayText)
                    .font(AppFonts.captionBold)
                    .foregroundColor(dueStatus.color)
                
                if let dueDate = item.dueDate {
                    Text(dueDate.shortDateString)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            // スワイプヒント
            Image(systemName: "chevron.left")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.textPlaceholder)
                .opacity(isSwiped ? 0 : 0.5)
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
    
    private func resetOffset() {
        withAnimation(AppConstants.springAnimation) {
            offset = 0
            isSwiped = false
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        Text("左にスワイプしてアクション")
            .foregroundColor(.secondary)
    }
    .padding()
    .background(AppColors.background)
}
