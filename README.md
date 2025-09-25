# Minesweeper — SwiftUI

Classic Minesweeper for iOS built with SwiftUI and MVVM. Clean UI, smooth zoom, flag mode, timer, and multiple difficulty levels. The initial tap never reveals a mine, improving overall user experience.

## Features
- Multiple difficulties: Easy, Normal, Hard
- Flag mode and long‑press to mark tiles
- Discrete zoom controls (50%–300%) for large grids
- Timer and remaining mines counter
- Safe first move: the initial tap never reveals a mine
- Polished tile design with clear contrast between closed and opened cells

## Tech stack
- Swift 5+, SwiftUI, MVVM
- Pure SwiftUI grid layout and tile rendering
- Foundation timers for elapsed time

## Architecture
- Models: `Minefield`, `Tile`, `Coordinate`
- ViewModel: `ViewModel` handles game lifecycle, mine placement, counters, flood fill, and timer
- Views: `ContentView`, `MinesweeperField`, `TileView`

## Gameplay
- Reveal tiles and clear the board without detonating a mine.
- Numbers indicate the count of adjacent mines.
- Flags help avoid accidental taps on suspected mines.

## Controls
- Tap: Reveal a tile (ignored if flagged)
- Long press: Cycle mark (🚩 → ? → clear)
- Flag mode: Switch taps to marking for faster flag placement
- Zoom − / +: Adjust grid size in discrete steps

## UX details
- Safe first move: mines are placed after the initial tap, excluding the tapped cell and its neighbors.
- Readable tiles with subtle highlight on closed cells and a light inner border on opened cells for better contrast.

## Project structure
- `Models/`: `Minefield.swift`, `Tile.swift`, `Coordinate.swift`
- `ViewModel/`: `ViewModel.swift`
- `Views/`: `ContentView.swift`, `MinesweeperField.swift`, `TileView.swift`
