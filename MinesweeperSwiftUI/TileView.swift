//
//  TileView.swift
//  MinesweeperSwiftUI
//
//  Created by Бадретдинов Владимир on 25.08.2025.
//

import SwiftUI

// MARK: - TileView

struct TileView: View {
    // MARK: Dependencies
    @ObservedObject var tile: Tile
    let tileSize: CGFloat
    
    // MARK: Content Colors
    private var numberColor: Color {
        switch tile.neighboringMines {
        case 1: return .blue
        case 2: return .green
        case 3: return .red
        case 4: return Color(.sRGB, red: 0.0, green: 0.2, blue: 0.6, opacity: 1.0)
        case 5: return Color(.sRGB, red: 0.5, green: 0.1, blue: 0.1, opacity: 1.0)
        case 6: return Color(.sRGB, red: 0.0, green: 0.5, blue: 0.5, opacity: 1.0)
        case 7: return .black
        case 8: return .gray
        default: return .black
        }
    }
    
    // MARK: Content Text
    private var contentText: String {
        if !tile.isRevealed {
            switch tile.mark {
            case .none: return ""
            case .flag: return "🚩"
            case .question: return "?"
            }
        } else {
            return tile.isMine ? "💣" : (tile.neighboringMines == 0 ? "" : "\(tile.neighboringMines)")
        }
    }
    
    // MARK: Body
    var body: some View {
        let r = max(3, tileSize * 0.14)
        
        ZStack {
            // MARK: Background
            if tile.isRevealed {
                RoundedRectangle(cornerRadius: r)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: r)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: r)
                    .fill(Color(.systemGray4))
                    .overlay(
                        RoundedRectangle(cornerRadius: r)
                            .stroke(Color(.systemGray), lineWidth: 1)
                    )
                    .overlay(
                        LinearGradient(
                            colors: [Color.white.opacity(0.30), .clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                        .clipShape(RoundedRectangle(cornerRadius: r))
                    )
            }
            
            // MARK: Foreground
            if tile.isRevealed {
                if tile.isMine {
                    Text("💣")
                        .font(.system(size: tileSize * 0.70, weight: .bold))
                        .minimumScaleFactor(0.5)
                } else if !contentText.isEmpty {
                    Text(contentText)
                        .font(.system(size: tileSize * 0.60, weight: .heavy, design: .monospaced))
                        .foregroundColor(numberColor)
                        .minimumScaleFactor(0.5)
                }
            } else {
                switch tile.mark {
                case .flag:
                    Text("🚩")
                        .font(.system(size: tileSize * 0.70))
                case .question:
                    Text("?")
                        .font(.system(size: tileSize * 0.70, weight: .semibold))
                        .foregroundColor(.secondary)
                case .none:
                    EmptyView()
                }
            }
        }
        .frame(width: tileSize, height: tileSize)
        .contentShape(Rectangle())
    }
}
