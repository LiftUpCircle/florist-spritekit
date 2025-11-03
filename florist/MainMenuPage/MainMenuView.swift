//
//  MainMenuView.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var controller = MainMenuViewController()

    var body: some View {
        NavigationStack(path: $controller.navigationPath) {
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
                                    controller.handleMenuSelection(item)
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
            .navigationDestination(for: MainMenuModel.MenuItem.self) { item in
                switch item {
                case .start:
                    BouquetView()
                case .memories:
                    MemoriesView()
                case .options:
                    Text("Options - Coming Soon")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
            }
        }
        .statusBar(hidden: true)
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
