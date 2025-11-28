//
//  RestartModalityDialog.swift
//  florist
//

import SwiftUI

struct RestartModalityDialog: View {
    @Binding var isPresented: Bool
    let onRestart: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                        onCancel()
                    }
                }

            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text("Thank you for supporting us by playing the game!\nOur game is still in Beta, and expect more growth is coming soon.")
                        .font(.bodyGaegu)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    Text("If you’d like to experience it again, you can restart the game to experience it all over.\nWould you like to restart the game?")
                        .font(.bodyGaegu)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                Divider()

                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            isPresented = false
                            onRestart()
                        }
                    }) {
                        Text("Yes")
                            .font(.bodyGaegu)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("DialogueTextbox"))
//                            .foregroundColor(Color(red: 0.294, green: 0.867, blue: 0.333))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .background(Color.green)

//                    Divider()
//                        .frame(height: 50)

                    Button(action: {
                        withAnimation {
                            isPresented = false
                            onCancel()
                        }
                    }) {
                        Text("No")
                            .font(.bodyGaegu)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("DialogueTextbox"))
//                            .foregroundColor(Color("DialogueTextBox"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .background(Color.red)
                }
            }
            .background(Color("DialogueTextbox"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(maxWidth: 469)
        }
    }
}

#Preview {
    RestartModalityDialog(
        isPresented: .constant(true),
        onRestart: { print("Restart") },
        onCancel: { print("Cancel") }
    )
}
