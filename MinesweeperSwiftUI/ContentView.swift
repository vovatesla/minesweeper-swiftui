//
//  ContentView.swift
//  MinesweeperSwiftUI
//
//  Created by Бадретдинов Владимир on 24.08.2025.
//

import SwiftUI
import UIKit

// MARK: - ContentView

struct ContentView: View {
    // MARK: - State & Constants
    @StateObject private var vm = ViewModel()
    @State private var showingPopover = false
    private let baseTileSize: CGFloat = 30
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            // MARK: Top Bar
            HStack {
                Button(action: { showingPopover = true }) {
                    Text("⚙️")
                        .font(.system(size: 30))
                        .frame(width: 50, height: 50)
                }
                .popover(isPresented: $showingPopover) {
                    // MARK: Popover
                    VStack(spacing: 15) {
                        HStack {
                            Button("❌") { showingPopover = false }
                                .font(.title2)
                            Spacer()
                        }
                        Text("Choose your difficulty:")
                            .font(.largeTitle)
                        Button("Easy 🐥") { vm.startNewGame(difficulty: .easy); showingPopover = false }
                            .font(.title2)
                        Button("Normal 🤲🏻") { vm.startNewGame(difficulty: .normal); showingPopover = false }
                            .font(.title2)
                        Button("Hard 👹") { vm.startNewGame(difficulty: .hard); showingPopover = false }
                            .font(.title2)
                    }
                    .padding()
                }
                
                Spacer()
                
                Text("\(vm.remainingMines)💣")
                    .font(.title2)
                    .frame(minWidth: 60)
                
                Button {
                    vm.restartGame()
                } label: {
                    Image(systemName: "memories")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .padding(6)
                }
                
                Text("\(vm.elapsedTime)")
                    .font(.title2)
                    .frame(minWidth: 60)
                
                Spacer()
                
                Button("Flag") {
                    vm.flagMode.toggle()
                }
                .font(.title2)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(vm.flagMode ? Color.blue.opacity(0.3) : Color.clear)
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            // MARK: Minefield
            MinesweeperField(vm: vm, tileSize: baseTileSize)
            // MARK: Alerts
                .alert("Game Over 💥", isPresented: $vm.isGameOver) {
                    Button("Restart", action: vm.restartGame)
                } message: {
                    Text("You hit a mine! Try again.")
                }
                .alert("You Win! 🎉", isPresented: $vm.isGameWon) {
                    Button("Restart", action: vm.restartGame)
                } message: {
                    Text("Congratulations, you cleared the minefield!")
                }
                .onAppear {
                    vm.debugPrint()
                }
        }
    }
}

#Preview {
    ContentView()
}
