//
//  Minefield.swift
//  MinesweeperSwiftUI
//
//  Created by Бадретдинов Владимир on 26.08.2025.
//

import Foundation

// MARK: - Minefield

struct Minefield {
    // MARK: Storage
    let difficulty: Difficulty
    var tiles: [Coordinate: Tile]
    var mines: [Coordinate] = []
    var remainingMines: Int
    
    // MARK: Computed Properties
    var gridSize: (x: Int, y: Int) { difficulty.gridSize }
    var minesCount: Int { difficulty.minesCount }
    var gridCoordinates: [Coordinate] { difficulty.getGridCoordinates() }
    var tilesArray: [Tile] {
        gridCoordinates
            .sorted { $0.y == $1.y ? $0.x < $1.x : $0.y < $1.y }
            .compactMap { tiles[$0] }
    }
    
    // MARK: Init
    @MainActor
    init(difficulty: Difficulty = .easy) {
        self.difficulty = difficulty
        self.remainingMines = difficulty.minesCount
        self.tiles = Self.generateTiles(for: difficulty)
    }
    
    // MARK: Setup
    @MainActor
    private static func generateTiles(for difficulty: Difficulty) -> [Coordinate: Tile] {
        var dict: [Coordinate: Tile] = [:]
        let gridCoords = difficulty.getGridCoordinates()
        for coord in gridCoords {
            dict[coord] = Tile(x: coord.x, y: coord.y, isMine: false)
        }
        return dict
    }
    
    // MARK: Gameplay
    @MainActor
    mutating func placeMines(excluding firstTap: Coordinate) {
        let forbidden = Set([firstTap] + firstTap.neighbors(maxX: gridSize.x, maxY: gridSize.y))
        let candidates = gridCoordinates.filter { !forbidden.contains($0) }

        for coord in gridCoordinates {
            if let t = tiles[coord] {
                t.isMine = false
                t.isRevealed = false
                t.mark = .none
                t.neighboringMines = 0
            }
        }

        let shuffled = candidates.shuffled()
        mines = Array(shuffled.prefix(minesCount))

        for coord in mines {
            tiles[coord]?.isMine = true
        }

        updateNeighboringMineCounts()

        remainingMines = minesCount
    }
    
    // MARK: Helpers
    @MainActor
    private mutating func updateNeighboringMineCounts() {
        for coord in gridCoordinates {
            tiles[coord]?.neighboringMines = 0
        }
        for mine in mines {
            for neighbor in mine.neighbors(maxX: gridSize.x, maxY: gridSize.y) {
                if let tile = tiles[neighbor], !tile.isMine {
                    tile.neighboringMines += 1
                }
            }
        }
    }
    
    // MARK: - Difficulty
    enum Difficulty {
        case easy, normal, hard
        
        var gridSize: (x: Int, y: Int) {
            switch self {
            case .easy: return (9, 9)
            case .normal: return (16, 16)
            case .hard: return (30, 16)
            }
        }
        
        var minesCount: Int {
            switch self {
            case .easy: return 10
            case .normal: return 40
            case .hard: return 99
            }
        }
        
        fileprivate func getGridCoordinates() -> [Coordinate] {
            var coords: [Coordinate] = []
            for x in 1...gridSize.x {
                for y in 1...gridSize.y {
                    coords.append(Coordinate(x: x, y: y))
                }
            }
            return coords
        }
    }
}
