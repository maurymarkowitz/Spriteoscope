//
//  SpriteoscopeView.swift
//  macOS
//
//  Created by Maury Markowitz on 2022-10-24.
//  Copyright © 2022 Maury Markowitz. All rights reserved.
//

import SwiftUI
import SpriteKit

struct SpriteoscopeView: View {
    @ObservedObject var scene = SpriteoscopeScene()
    @State private var showInfoPanel = false

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)

            ZStack {
                Color.gray
                    .ignoresSafeArea()

                SpriteView(scene: scene)
                    .frame(width: side, height: side)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                VStack {
                    HStack {
                        Button(action: { withAnimation(.easeInOut) { showInfoPanel.toggle() } }, label: {
                            ZStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 34, height: 34)
                                Image("more-info-icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                        })
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 34, height: 34)
                        .help("About Spriteoscope")

                        Spacer()

                        Button(action: { scene.setupKalidescope() }, label: {
                            ZStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 34, height: 34)
                                Image("undo-circle-outline-icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                        })
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 34, height: 34)
                        .help("Restart")

                        Button(action: { scene.pauseKalidescope() }, label: {
                            ZStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 34, height: 34)
                                Image(!scene.myPaused ? "pause-button-round-icon" : "play-button-round-icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                        })
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 34, height: 34)
                        .help(!scene.myPaused ? "Pause" : "Play")
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.horizontal, .top])

                    Spacer()
                }

                if showInfoPanel {
                    InfoPanelView(showInfo: $showInfoPanel)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
            }
        }
        .frame(minWidth: 640, minHeight: 500)
    }

}

struct InfoPanelView: View {
    @Binding var showInfo: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Spriteoscope v1.0")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Image("info-animation")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 420, maxHeight: 220)
                .background(Color.black)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )

            ScrollView {
                Text("Spriteoscope is a recreation of the original Cromemco Dazzler kaleidoscope. This screen slides into view from the bottom and provides a quick demo panel inside the app window.")
                    .foregroundColor(.white)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
            .frame(maxHeight: 120)

            Button(action: { withAnimation(.easeInOut) { showInfo = false } }) {
                Text("Close")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(14)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(24)
        .frame(maxWidth: 520)
        .background(Color.black)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.6), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
    }
}

struct AboutView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Spriteoscope v1.0")
                Spacer()
                Text("Spriteoscope is a recreation of one of the world's first bits of demoware. Released in 1976 for S-100 machines with the Cromemco Dazzler graphics card, a machine was set up in a computer store window in New York City and caused a traffic jam on 5th Avenue that required the police to come and order people to move along. It's a trivially simple program, but the patterns it creates are mesmerizing.").lineLimit(nil)
                Spacer()
            }
            Spacer()
        }
        .frame(minWidth: 300, minHeight: 300)
    }
}
