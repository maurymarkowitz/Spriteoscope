//
//  GameViewController.swift
//  Spriteoscope macOS
//
//  Created by Maury Markowitz on 2022-10-08.
//

import Cocoa
import SwiftUI
import SpriteKit
import GameplayKit

/// SwiftUI uses UserInterfaceSizeClass to adjust for layout changes,
/// but fails to add these on macOS. These stubs add the correct structs
/// to allow the same SwiftUI layout to work on either platform, with
/// macOS simply returning .regular at all times.
///
/// NOTE: its possible Apple will add this functionality to macOS at
/// some point and this should be removed.
#if os(macOS)
enum UserInterfaceSizeClass {
    case compact
    case regular
}

struct HorizontalSizeClassEnvironmentKey: EnvironmentKey {
    static let defaultValue: UserInterfaceSizeClass = .regular
}
struct VerticalSizeClassEnvironmentKey: EnvironmentKey {
    static let defaultValue: UserInterfaceSizeClass = .regular
}

extension EnvironmentValues {
    var horizontalSizeClass: UserInterfaceSizeClass {
        get { return self[HorizontalSizeClassEnvironmentKey.self] }
        set { self[HorizontalSizeClassEnvironmentKey.self] = newValue }
    }
    var verticalSizeClass: UserInterfaceSizeClass {
        get { return self[VerticalSizeClassEnvironmentKey.self] }
        set { self[VerticalSizeClassEnvironmentKey.self] = newValue }
    }
}
#endif

class GameViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SpriteoscopeScene.newSpriteoscopeScene()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
    }

}
