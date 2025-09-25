//
//  ViewModel.swift
//  MinesweeperSwiftUI
//
//  Created by Бадретдинов Владимир on 27.08.2025.
//

import Foundation

// MARK: - ViewModel

@MainActor
final class ViewModel: ObservableObject {
    // MARK: State
    @Published private var mineField = Minefield(difficulty: .normal)
    @Published private(set) var difficulty: Minefield.Difficulty = .normal
    @Published var isGameOver = false
    
    @Published var elapsedTime: Int = 0
    @Published var openedTilesCount: Int = 0
    @Published var isGameWon = false
    @Published var flagMode = false
    
    private var firstTapDone = false
    private var timer: Timer?
    
    // MARK: Computed Properties
    var remainingMines: Int { mineField.remainingMines }
    var gridSize: (x: Int, y: Int) { mineField.gridSize }
    var totalTiles: Int { gridSize.x * gridSize.y }
    var tilesArray: [Tile] { mineField.tilesArray }
    
    var tiles: [[Tile]] {
        var result: [[Tile]] = Array(repeating: [], count: gridSize.y)
        for y in 0..<gridSize.y {
            for x in 0..<gridSize.x {
                if let tile = mineField.tiles[Coordinate(x: x, y: y)] {
                    result[y].append(tile)
                }
            }
        }
        return result
    }
    
    // MARK: Game Lifecycle
    func startNewGame(difficulty: Minefield.Difficulty) {
        self.difficulty = difficulty
        resetGameState()
        mineField = Minefield(difficulty: difficulty)
        flagMode = false
    }
    
    func restartGame() {
        resetGameState()
        mineField = Minefield(difficulty: difficulty)
        flagMode = false
    }

    // MARK: Private Reset
    private func resetGameState() {
        firstTapDone = false
        isGameOver = false
        isGameWon = false
        elapsedTime = 0
        openedTilesCount = 0
        stopTimer()
        flagMode = false
    }
    
    // MARK: Timer
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedTime += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: Game End
    func gameOver() {
        isGameOver = true
        revealAllMines()
        stopTimer()
        flagMode = false
    }

    private func revealAllMines() {
        for mine in mineField.tilesArray.filter({ $0.isMine }) {
            mine.isRevealed = true
        }
    }
    
    // MARK: Player Actions
    func cycleMark(at coordinates: Coordinate) {
        guard let tile = mineField.tiles[coordinates] else { return }
        switch tile.mark {
        case .none:
            if mineField.remainingMines > 0 {
                tile.mark = .flag
                mineField.remainingMines -= 1
            }
        case .flag:
            tile.mark = .question
            mineField.remainingMines += 1
        case .question:
            tile.mark = .none
        }
    }
    
    func tapTile(at coordinates: Coordinate) {
        guard !isGameOver else { return }
        guard let tile = mineField.tiles[coordinates] else { return }
        
        if !firstTapDone {
            firstTapDone = true
            mineField.placeMines(excluding: coordinates)
            startTimer()
        }
        
        if tile.mark == .flag { return }
        
        if tile.isRevealed, tile.neighboringMines > 0 {
            let ncoords = coordinates.neighbors(maxX: mineField.gridSize.x, maxY: mineField.gridSize.y)
            let neighbors = ncoords.compactMap { mineField.tiles[$0] }
            let flagged = neighbors.filter { $0.mark == .flag }.count
            
            if flagged == tile.neighboringMines {
                for n in neighbors where !n.isRevealed && n.mark == .none {
                    if n.isMine {
                        gameOver()
                        return
                    }
                    n.isRevealed = true
                    if n.neighboringMines == 0 {
                        revealConnectedZeros(at: n.coordinates)
                        if isGameOver { return }
                    }
                }
            }
            debugTiles()
            return
        }
        
        if !tile.isRevealed {
            if tile.isMine {
                gameOver()
                return
            }
            tile.isRevealed = true
            updateOpenedTilesCount()
            if tile.neighboringMines == 0 {
                revealConnectedZeros(at: tile.coordinates)
            }
        }
        debugTiles()
    }
    
    // MARK: Flood Fill
    func revealConnectedZeros(at coordinates: Coordinate) {
        guard let start = mineField.tiles[coordinates] else { return }
        if start.isMine {
            gameOver()
            return
        }
        guard start.neighboringMines == 0 else { return }
        
        var queue: [Coordinate] = [coordinates]
        var visited: Set<Coordinate> = [coordinates]
        
        start.isRevealed = true
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            for neighbor in current.neighbors(maxX: mineField.gridSize.x, maxY: mineField.gridSize.y) {
                guard let tile = mineField.tiles[neighbor] else { continue }
                guard !visited.contains(neighbor) else { continue }
                guard !tile.isRevealed else { continue }
                guard tile.mark != .flag else { continue }
                
                visited.insert(neighbor)
                
                if tile.isMine {
                    gameOver()
                    return
                }
                
                tile.isRevealed = true
                if tile.neighboringMines == 0 {
                    queue.append(neighbor)
                }
            }
        }
        updateOpenedTilesCount()
        debugTiles()
    }
    
    // MARK: Counters
    private func updateOpenedTilesCount() {
        openedTilesCount = mineField.tilesArray.filter { $0.isRevealed }.count

        let totalSafeTiles = totalTiles - mineField.minesCount
        if openedTilesCount == totalSafeTiles && !isGameOver {
            isGameWon = true
            stopTimer()
        }
    }
    
    // MARK: Debug
    func debugTiles() {
        let ys = mineField.tiles.keys.map { $0.y }
        let minY = ys.min() ?? -1
        let maxY = ys.max() ?? -1
        print("tiles count = \(mineField.tiles.count), y-range = \(minY)...\(maxY)")
    }
    
    func debugPrint() {
        print("difficulty is \(difficulty)")
        print("gridSize is \(mineField.gridSize)")
        print("tiles count = \(mineField.tiles.count)")
    }
}
