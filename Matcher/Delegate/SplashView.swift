//
//  SplashView.swift
//  Attendance
//
//  Created by POSSIBILITY on 24/04/25.
//

import Foundation
import SwiftUI

struct SplashView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var isActive = false

    var body: some View {
        Group {
            if isActive {
                ContentView()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [.splashTop, .splashBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    VStack(spacing: 0) {
                        Text("A Smart, Safe & Simple Way to Find Rooms and Verified Roommates.")
                            .font(AppFont.manropeBold(32))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, 30)
                        Text("Find budget-friendly rooms and like-minded roommates near you.")
                            .font(AppFont.manrope(16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                            .padding(.horizontal, 40)
                        Button {
                            isActive = true
                        } label: {
                            Text("Find a Room")
                                .font(AppFont.manropeSemiBold(18))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(AppColors.primaryYellow)
                                .cornerRadius(35)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 30)
                        Spacer()
                        Image("girl")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                    } .padding(.top, 85)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
            }
        }
        .environmentObject(userAuth)
    }
}

