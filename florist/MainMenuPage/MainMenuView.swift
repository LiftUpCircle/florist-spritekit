//
//  MainMenuView.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var controller = MainMenuViewController()
    @StateObject private var flowCoordinator = GameFlowCoordinator()

    var body: some View {
        NavigationStack(path: $flowCoordinator.navigationPath) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color(red: 0.85, green: 0.85, blue: 0.87)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Menu panel on the right side
                HStack {
                    Spacer()
                        VStack(/*spacing: 40*/) {
                            ForEach(controller.model.menuItems, id: \.self) { item in
                                MenuButton(title: item.rawValue) {
                                    handleMenuSelection(item)
                                }
                                .padding(.vertical,5)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.gray.opacity(0.6))
                        )
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: GameFlowCoordinator.GamePage.self) { page in
                switch page {
                case .listening(let storyId):
                    ListeningPageView(storyId: storyId, flowCoordinator: flowCoordinator)
                case .bouquet(let storyId):
                    BouquetPageWrapper(storyId: storyId, flowCoordinator: flowCoordinator)
                case .memories:
                    MemoriesView()
                case .options:
                    Text("Options - Coming Soon")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                case .mainMenu:
                    EmptyView() // This shouldn't be reached
                }
            }
        }
        .statusBar(hidden: true)
        .environmentObject(flowCoordinator)
    }
    
    private func handleMenuSelection(_ item: MainMenuModel.MenuItem) {
        switch item {
        case .start:
            flowCoordinator.startNewGame()
        case .memories:
            flowCoordinator.navigateToMemories()
        case .options:
            flowCoordinator.navigateToOptions()
        }
    }
}

struct MenuButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Arial Rounded MT Bold", size: 40))
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.leading, 16)
                .padding(.trailing, 86)
        }
    }
}

#Preview {
    MainMenuView()
}
