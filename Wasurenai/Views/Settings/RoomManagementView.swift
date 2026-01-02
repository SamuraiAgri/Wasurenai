//
//  RoomManagementView.swift
//  Wasurenai
//
//  Created by rinka on 2026/01/02.
//

import SwiftUI

/// 部屋管理画面
struct RoomManagementView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: RoomManagementViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: RoomManagementViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.rooms, id: \.objectID) { room in
                    RoomRow(room: room) {
                        viewModel.startEditing(room: room)
                    }
                }
                .onMove { source, destination in
                    viewModel.move(from: source, to: destination)
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let room = viewModel.rooms[index]
                        if !room.isDefault {
                            viewModel.delete(room: room)
                        }
                    }
                }
            } header: {
                Text("部屋一覧")
            } footer: {
                Text("スワイプで削除、長押しで並べ替えができます。\n初期の部屋は削除できません。")
            }
            
            Section {
                Button {
                    viewModel.startAdding()
                } label: {
                    Label("新しい部屋を追加", systemImage: "plus.circle.fill")
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .navigationTitle("部屋の管理")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
        .sheet(isPresented: $viewModel.isShowingEditor) {
            RoomEditorSheet(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadRooms()
        }
    }
}

// MARK: - Room Row

struct RoomRow: View {
    
    let room: Room
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: AppConstants.paddingSmall) {
                // アイコン
                ZStack {
                    Circle()
                        .fill(Color(hex: room.colorHex ?? AppColors.categoryColors[0]).opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: room.iconName ?? "house.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: room.colorHex ?? AppColors.categoryColors[0]))
                }
                
                // 名前
                Text(room.name ?? "")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                // デフォルトバッジ
                if room.isDefault {
                    Text("初期")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.secondaryBackground)
                        .cornerRadius(8)
                }
                
                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textPlaceholder)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Room Editor Sheet

struct RoomEditorSheet: View {
    
    @ObservedObject var viewModel: RoomManagementViewModel
    @State private var showingIconPicker = false
    @State private var showingColorPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // 名前
                    HStack {
                        Text("名前")
                            .foregroundColor(AppColors.textSecondary)
                        TextField("部屋名を入力", text: $viewModel.editName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    // アイコン選択
                    Button {
                        showingIconPicker = true
                    } label: {
                        HStack {
                            Text("アイコン")
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Image(systemName: viewModel.editIconName)
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: viewModel.editColorHex))
                            Image(systemName: AppIcons.chevronRight)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.textPlaceholder)
                        }
                    }
                    
                    // 色選択
                    Button {
                        showingColorPicker = true
                    } label: {
                        HStack {
                            Text("カラー")
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Circle()
                                .fill(Color(hex: viewModel.editColorHex))
                                .frame(width: 24, height: 24)
                            Image(systemName: AppIcons.chevronRight)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.textPlaceholder)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.editorTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        viewModel.cancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        viewModel.save()
                    }
                    .disabled(!viewModel.canSave)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerSheet(
                    selectedIconName: $viewModel.editIconName,
                    selectedColor: Color(hex: viewModel.editColorHex),
                    icons: roomIcons
                )
            }
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerView(selectedColorHex: $viewModel.editColorHex)
            }
        }
    }
    
    private var roomIcons: [String] {
        [
            "house.fill", "toilet.fill", "bathtub.fill", "refrigerator.fill",
            "sofa.fill", "bed.double.fill", "sink.fill", "door.left.hand.closed",
            "car.fill", "bicycle", "building.2.fill", "tree.fill",
            "washer.fill", "fan.fill", "lamp.desk.fill", "tv.fill",
            "gamecontroller.fill", "book.fill", "paintbrush.fill", "wrench.fill",
            "ellipsis.circle.fill"
        ]
    }
}

#Preview {
    NavigationStack {
        RoomManagementView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
