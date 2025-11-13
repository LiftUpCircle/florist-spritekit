//
//  FlowerBookView.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 06/11/25.
//

import SwiftUI
import Combine

struct FlowerBookView: View {
    var onDismiss: () -> Void
    
    @StateObject private var viewModel = FlowerBookViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss()
                    }
                
                if !viewModel.flowers.isEmpty, let currentFlower = viewModel.currentFlower {
                    HStack(spacing: 0) {
                        
                        FlowerSidebarView(
                            flowers: viewModel.flowers,
                            currentIndex: viewModel.currentFlowerIndex,
                            onFlowerSelected: { index in
                                viewModel.selectFlower(at: index)
                            }
                        )
                        .frame(width: geometry.size.width * 0.18, height: geometry.size.height)
                        .padding(.leading, geometry.size.width * 0.02)
                        
                        Spacer()
                        
                        
                        ZStack {
                            
                            Image("FlowerBook")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: min(geometry.size.width * 0.65, 650),
                                       height: min(geometry.size.height * 0.85, 850))
                            
                            
                            BookContentView(
                                flower: currentFlower,
                                onPrevious: {
                                    viewModel.goToPrevious()
                                },
                                onNext: {
                                    viewModel.goToNext()
                                },
                                canGoPrevious: viewModel.canGoPrevious,
                                canGoNext: viewModel.canGoNext
                            )
                            .frame(width: min(geometry.size.width * 0.65, 650),
                                   height: min(geometry.size.height * 0.85, 850))
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .statusBar(hidden: true)
    }
}

#Preview {
    FlowerBookView(onDismiss: {})
}

