//
//  SpriteoscopeScene.swift
//  Spriteoscope
//
//  Created by Maury Markowitz on 2022-10-04.
//

import SpriteKit

let VERSION_STRING = "2.0"

@MainActor
class SpriteoscopeScene: SKScene, ObservableObject {
    @Published var myPaused = false
    
    // these four variables are the entire program state
    var oldX : UInt8 = 0
    var oldY : UInt8 = 0
    var mask : UInt8 = 0
    var color : Int = 15 // starts at 15, use an Int (instead of UInt) to simplify the dictionary below
    
    // and this one is new, it tracks the number of consecutive frames drawn
    var loop : UInt8 = 63 // this steps down in the original code, so do the same here
    
    // we need to track all of the nodes we're going to use to draw the grid
    // so we can change their colors during the main loop. we could possibly
    // do this using the node's tag, but then you'd have to search all 4k nodes
    // every time
    var grid = [[SKSpriteNode]]()
    private var packedMemory = [UInt8]()
    
    // size of the grid, for code clarity
    let numCols = 64
    let numRows = 64
    
    // each byte in the original Dazzler memory encodes two pixels:
    // high nibble for even x, low nibble for odd x
    // we track it here to more clearly mirror the 8080 logic.
    
    // the original code ran on a 2 MHz Altair; each inner iteration
    // takes ~892 cycles, giving ~2250 iterations/sec at 2 MHz.
    // we'll use a timer instead of using the Scene's natural 60 fps updates
    var timer = Timer()
    
    // and let you pick the looping rate
    let loopspersecond = 2250.0
    
    // and an enum to hold the Dazzler's 16 colors
    let colormap = [
        0: SKColor.black,
        1: SKColor(red: 0.5, green: 0, blue: 0, alpha: 1),      // dim red
        2: SKColor(red: 0, green: 0.5, blue: 0, alpha: 1),      // dim green
        3: SKColor(red: 0.5, green: 0.5, blue: 0, alpha: 1),    // dim yellow
        4: SKColor(red: 0, green: 0, blue: 0.5, alpha: 1),      // dim blue
        5: SKColor(red: 0.5, green: 0, blue: 0.5, alpha: 1),    // dim purple
        6: SKColor(red: 0, green: 0.5, blue: 0.5, alpha: 1),    // dim cyan
        7: SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1),  // grey
        8: SKColor.black,
        9: SKColor.red,
        10: SKColor.green,
        11: SKColor.yellow,
        12: SKColor.blue,
        13: SKColor.purple,
        14: SKColor.cyan,
        15: SKColor.white
    ]

    // if you select multiplatform as the starting point for your project,
    // the template code calls this function to do setup. If you select
    // macOS only, it puts this code in the ViewController. That seems odd.
    class func newSpriteoscopeScene() -> SpriteoscopeScene {
        guard let scene = SKScene(fileNamed: "SpriteoscopeScene") as? SpriteoscopeScene else {
            print("Failed to load SpriteoscopeScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .resizeFill
        
        return scene
    }

    // this is, for all intents, the init method for Scenes
    override func didMove(to view: SKView) {
        // not sure where this is being set, but in SwiftUI this defaults to 0,0
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // set up the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / loopspersecond,
                                     repeats: true,
                                     block: { _ in self.updateKalidescope() }
                                     )
        
        setupKalidescope()
    }
    
    // sets up the initial state, called when first starting the app
    // or hitting reset while its running
    func setupKalidescope() {
        // this may be called while it's running, so there are any
        // sprites in the scene already, just delete them
        self.removeAllChildren()
        grid.removeAll()
        packedMemory = [UInt8](repeating: 0, count: numRows * numCols / 2)
        
        // and the reset might be while it's paused
        DispatchQueue.main.async {
            self.myPaused = false
        }
        
        // we're mapping the original 64 x 64 pattern to fill a potentially
        // varying viewport size, so here we determine the size of the "pixels"
        let pixelSize = min(self.size.width / Double(numCols), self.size.height / Double(numRows))
        
        // set up the initial state, which in this case is random values
        oldX = UInt8.random(in: 0...255) // see notes in draw below
        oldY = UInt8.random(in: 0...255)
        mask = UInt8.random(in: 0...255)
        color = Int.random(in: 1...15)
        
        // now create a series of SKNodes to represent the pixels,
        // and save them in the grid for future reference
        for row in 0..<numRows {
            // Swift 2D arrays are dumb, you have to create a row thus...
            grid.append([])

            for col in 0..<numCols {
                // make a new node and set it to the background color
                let n = SKSpriteNode.init(color: SKColor.black, size:CGSize(width: pixelSize, height: pixelSize))
                
                // our screen is -size.width/2...size.width/2, the original is numColumns, so convert
                let xloc = pixelSize * Double(col - (numCols / 2))
                let yloc = pixelSize * Double(row - (numRows / 2))
                n.position = CGPoint.init(x:xloc, y:yloc)
                
                // add it to the grid array for this row
                grid[row].append(n)
                
                // and add it to the scene
                self.addChild(n)
            }
        }
    }
    
    // this is the main display method, called for every cycle
    //
    // the logic is basically this:
    //
    // there is an outer infinite loop at the application level
    //
    // every time through the loop, a new X and Y location is calculated
    //    and the pixel at that location is updated with the current color,
    //    as well as the three mirrored locations of that pixel
    //
    // the color is black every odd time through the loop, and a non-black
    //    color every even time
    //
    // every 64th loop the mask is updated and X and Y changed, which causes
    //    the pattern to "jump" to a new location and make it more random,
    //    and the draw color is changed. There are 16 colors in total, it
    //    steps though them all one by one
    //
    func updateKalidescope() {
        if myPaused { return }
        
        // select new X and Y locations, which happens every loop
        // the &+ means "add and roll over, don't report overflow"
        let newY = oldY &+ ((oldX >> 2) & mask)
        let newX = oldX &- ((newY >> 2) & mask)

        // the original 8080 Dazzler code stores two pixels per byte.
        // We choose the nibble based on x parity to mirror that packed format:
        // even x -> high nibble, odd x -> low nibble.
        let colorNibble: UInt8 = loop % 2 == 0 ? 0 : UInt8(color & 0x0F)

        let ourX = Int(newX) / 8
        let ourY = Int(newY) / 8

        updatePackedPixel(x: ourX + 32, y: ourY + 32, colorIndex: colorNibble)
        updatePackedPixel(x: 32 - ourX, y: ourY + 32, colorIndex: colorNibble)
        updatePackedPixel(x: 32 - ourX, y: 32 - ourY, colorIndex: colorNibble)
        updatePackedPixel(x: ourX + 32, y: 32 - ourY, colorIndex: colorNibble)

        // now our new X and Y become the old X and Y
        oldX = newX
        oldY = newY
        
        // see if this is the 64th loop, and update if it is
        loop -= 1
        if loop == 0 {
            // reset it
            loop = 63
            
            // bump X and Y
            oldX &+= 1
            oldY &+= 1

            color -= 1  // change the color
            // if that made it black...
            if color == 0 {
                color = 15  // reset it
                mask &+= 1   // and change the mask
            }
        }
    }
    
    func updatePackedPixel(x: Int, y: Int, colorIndex: UInt8) {
        guard x >= 0 && x < numCols && y >= 0 && y < numRows else { return }
        let byteIndex = y * (numCols / 2) + (x / 2)
        let currentByte = packedMemory[byteIndex]

        let newByte: UInt8
        if x % 2 == 0 {
            newByte = (currentByte & 0x0F) | (colorIndex << 4)
        } else {
            newByte = (currentByte & 0xF0) | (colorIndex & 0x0F)
        }

        packedMemory[byteIndex] = newByte
        let pixelColor = colormap[Int(colorIndex)] ?? SKColor.black
        grid[y][x].color = pixelColor
    }

    func pauseKalidescope() {
        myPaused = !myPaused
    }

    // new X and Y positions are rolled
    func rollRight(_ input: UInt8, _ amount: UInt8) -> UInt8 {
        let amount = amount % 8 // Reduce to the range 0...7
        return (input >> amount) | (input << (8 - amount))
    }

}
