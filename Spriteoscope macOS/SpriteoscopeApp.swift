//
//  SpriteoscopeApp.swift
//  Spriteoscope macOS
//
//  Created by Maury Markowitz on 2022-12-11.
//

import SwiftUI
import AppKit

@main
struct SpriteoscopeApp: App {
    // the delegate takes care of the app-level things, like the about menu and such
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SpriteoscopeView()
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button(action: {
                    appDelegate.showAboutPanel()
                }) {
                    Text("About Spriteoscope")
                }
            }
        }
    }
    
    class AppDelegate: NSObject, NSApplicationDelegate {
        private var aboutBoxWindowController: NSWindowController?
        
        func applicationDidFinishLaunching(_ notification: Notification) {
            removeDefaultMenus()
        }
        
        private func removeDefaultMenus() {
            guard let mainMenu = NSApp.mainMenu else { return }
            for item in mainMenu.items.reversed() {
                if ["Edit", "View", "Window", "Help"].contains(item.title) {
                    mainMenu.removeItem(item)
                }
            }
        }

        func showAboutPanel() {
            if aboutBoxWindowController == nil {
                let styleMask: NSWindow.StyleMask = [.closable, .miniaturizable, /* .resizable,*/ .titled]
                let window = NSWindow()
                window.styleMask = styleMask
                window.title = "About Spriteoscope"
                window.contentView = NSHostingView(rootView: AboutView())
                aboutBoxWindowController = NSWindowController(window: window)
            }
            
            aboutBoxWindowController?.showWindow(aboutBoxWindowController?.window)
        }
    }
    
    
}
