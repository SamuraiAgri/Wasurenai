//
//  EmptyStateView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// データが空の時に表示するビュー
struct EmptyStateView: View {
    
    let iconName: String
    let title: String
    let subtitle: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    
    var body: some View {
        VStack(spacing: AppConstants.paddingLarge) {
            // アイコン
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: iconName)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(AppColors.primary.opacity(0.6))
            }
            
            // テキスト
            VStack(spacing: AppConstants.paddingSmall) {
                Text(title)
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // アクションボタン（オプション）
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: AppIcons.addCircle)
                        Text(actionTitle)
                    }
                    .font(AppFonts.bodyBold)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppConstants.paddingLarge)
                    .padding(.vertical, AppConstants.paddingMedium)
                    .background(AppColors.primaryGradient)
                    .cornerRadius(AppConstants.cornerRadiusLarge)
                }
                .pressableStyle()
            }
        }
        .padding(AppConstants.paddingLarge)
    }
}

#Preview {
    EmptyStateView(
        iconName: "list.bullet.rectangle",
        title: AppStrings.homeEmpty,
        subtitle: AppStrings.homeEmptySubtitle,
        action: { },
        actionTitle: AppStrings.actionAdd
    )
}
