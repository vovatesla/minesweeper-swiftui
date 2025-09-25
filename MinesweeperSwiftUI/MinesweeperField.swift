//
//  MinesweeperField.swift
//  MinesweeperSwiftUI
//
//  Created by Бадретдинов Владимир on 09.09.2025.
//

import SwiftUI

// MARK: - MinesweeperField

struct MinesweeperField: View {
    // MARK: State
    @ObservedObject var vm: ViewModel
    @State var tileSize: CGFloat
    
    // MARK: Zoom
    @State private var zoomPercent: Int = 100
    private let minPercent = 50
    private let maxPercent = 300
    private let stepPercent = 20
    
    // MARK: Computed Properties
    private var actualTileSize: CGFloat {
        tileSize * CGFloat(zoomPercent) / 100
    }
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 8) {
            // MARK: Zoom Controls
            HStack {
                Button("-") {
                    zoomPercent = max(minPercent, zoomPercent - stepPercent)
                }
                .frame(width: 35, height: 35)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
                
                Text("Zoom: \(zoomPercent)%")
                    .font(.caption)
                    .frame(width: 90)
                
                Button("+") {
                    zoomPercent = min(maxPercent, zoomPercent + stepPercent)
                }
                .frame(width: 35, height: 35)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            // MARK: Grid
            ScrollView([.horizontal, .vertical]) {
                Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                    ForEach(vm.tiles.indices, id: \.self) { row in
                        GridRow {
                            ForEach(vm.tiles[row].indices, id: \.self) { col in
                                TileView(tile: vm.tiles[row][col], tileSize: actualTileSize)
                                    .onTapGesture {
                                        if vm.flagMode {
                                            vm.cycleMark(at: vm.tiles[row][col].coordinates)
                                        } else {
                                            vm.tapTile(at: vm.tiles[row][col].coordinates)
                                        }
                                    }
                                    .onLongPressGesture {
                                        vm.cycleMark(at: vm.tiles[row][col].coordinates)
                                    }
                            }
                        }
                    }
                }
                .padding(10)
            }
        }
    }
}
