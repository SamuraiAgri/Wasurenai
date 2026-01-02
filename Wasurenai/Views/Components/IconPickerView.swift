//
//  IconPickerView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// アイコン選択シート
struct IconPickerSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIconName: String
    let selectedColor: Color
    let icons: [String]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                IconPickerView(
                    selectedIconName: $selectedIconName,
                    icons: icons,
                    accentColor: selectedColor
                )
                .padding(AppConstants.paddingMedium)
            }
            .navigationTitle("アイコンを選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

/// アイコン選択ビュー
struct IconPickerView: View {
    
    @Binding var selectedIconName: String
    let icons: [String]
    let accentColor: Color
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(icons, id: \.self) { iconName in
                IconCell(
                    iconName: iconName,
                    isSelected: selectedIconName == iconName,
                    accentColor: accentColor
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedIconName = iconName
                    }
                }
            }
        }
        .padding(.vertical, AppConstants.paddingSmall)
    }
}

/// アイコンセル
private struct IconCell: View {
    
    let iconName: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: AppConstants.cornerRadiusSmall)
                    .fill(isSelected ? accentColor.opacity(0.15) : AppColors.secondaryBackground)
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? accentColor : AppColors.textSecondary)
            }
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadiusSmall)
                    .strokeBorder(
                        isSelected ? accentColor : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    IconPickerView(
        selectedIconName: .constant(AppIcons.itemIcons[0]),
        icons: AppIcons.itemIcons,
        accentColor: AppColors.primary
    )
    .padding()
}
