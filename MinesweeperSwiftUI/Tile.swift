//
//  Tile.swift
//  MinesweeperSwiftUI
//
//  Created by Бадретдинов Владимир on 26.08.2025.
//

import Foundation

// MARK: - Tile

@MainActor
final class Tile: Identifiable, ObservableObject {
    
    // MARK: Types & Stored Properties
    enum Mark { case none, flag, question }

    let x: Int
    let y: Int
    var coordinates: Coordinate { Coordinate(x: x, y: y) }
    var isMine: Bool
    
    nonisolated let id = UUID()
    
    // MARK: State
    @Published var isRevealed: Bool = false
    @Published var neighboringMines: Int = 0
    @Published var mark: Mark = .none
    
    // MARK: Init
    init(x: Int, y: Int, isMine: Bool) {
        self.x = x
        self.y = y
        self.isMine = isMine
    }
}

// MARK: - Coordinate

struct Coordinate: Hashable, Comparable {

    let x: Int
    let y: Int
    
    // MARK: Comparable
    static func < (lhs: Coordinate, rhs: Coordinate) -> Bool {
        if lhs.y == rhs.y { return lhs.x < rhs.x }
        return lhs.y < rhs.y
    }
    
    // MARK: Neighbors
    func neighbors(maxX: Int, maxY: Int) -> [Coordinate] {
        var coords: [Coordinate] = []
        for dx in -1...1 {
            for dy in -1...1 {
                if dx == 0 && dy == 0 { continue }
                let nx = x + dx
                let ny = y + dy
                if nx >= 1 && nx <= maxX && ny >= 1 && ny <= maxY {
                    coords.append(Coordinate(x: nx, y: ny))
                }
            }
        }
        return coords
    }
}
