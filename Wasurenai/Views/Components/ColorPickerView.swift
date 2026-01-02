//
//  ColorPickerView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// カラー選択シート
struct ColorPickerView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColorHex: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ColorPickerGridView(
                    selectedColorHex: $selectedColorHex,
                    colors: AppColors.categoryColors
                )
                .padding(AppConstants.paddingMedium)
            }
            .navigationTitle("カラーを選択")
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

/// カラー選択ビュー
struct ColorPickerGridView: View {
    
    @Binding var selectedColorHex: String
    let colors: [String]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(colors, id: \.self) { colorHex in
                ColorCell(
                    colorHex: colorHex,
                    isSelected: selectedColorHex == colorHex
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedColorHex = colorHex
                    }
                }
            }
        }
        .padding(.vertical, AppConstants.paddingSmall)
    }
}

/// カラーセル
private struct ColorCell: View {
    
    let colorHex: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(hex: colorHex))
                    .frame(width: 44, height: 44)
                
                if isSelected {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: AppIcons.check)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .shadow(color: Color(hex: colorHex).opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ColorPickerView(
        selectedColorHex: .constant(AppColors.categoryColors[0])
    )
}
