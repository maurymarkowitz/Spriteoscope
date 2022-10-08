//
//  GameScene.swift
//  Spriteoscope
//
//  Created by Maury Markowitz on 2022-10-04.
//

import SpriteKit

class GameScene: SKScene {
    // these four variables are the entire program state
    var X : UInt8 = 0
    var Y : UInt8 = 0
    var mask : UInt8 = 0
    var color : Int  = 15 // starts at 15, use an Int to simplify the dictionary below
    
    // and this one is new, it tracks the number of consecutive frames drawn
    var loop : UInt8 = 63 // this steps down in the original code, so do the same here
    
    // and we need to track all of the nodes we're going to use to draw the grid
    // so we can change their colors during the main loop
    var grid = [[SKSpriteNode]]()
    
    // size of the grid, for code clarity
    let numColumns = 64
    let numRows = 64
    
    // the original code runs at about 80 loops per second, so we'll use a timer
    // instead of using the Scene's natural 60 fps updates
    var timer = Timer()
    
    // and let you pick the looping rate
    let loopspersecond = 180.0

    // and an enum to hold the Dazzler's 16 colors
    let colormap = [0: SKColor.black,
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
    // macOS only, it puts this code in the ViewController. That seems odd
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }

    // this is, for all intents, the init method for Scenes
    override func didMove(to view: SKView) {
        // set up the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / loopspersecond,
                                     repeats: true,
                                     block: { _ in self.updateKalidescope() }
                                     )
                                     
        // we're mapping the original 64 x 64 pattern to fill a potentially
        // varying viewport size, so here we determine the size of the "pixels"
        let pixelSize = min(self.size.width / Double(numColumns), self.size.height / Double(numRows))
        
        // set up the initial state, which in this case is random values
        X = UInt8.random(in: 0...255) // see notes in draw below
        Y = UInt8.random(in: 0...255)
        mask = UInt8.random(in: 0...255)
        color = Int.random(in: 1...15)
        
        // now create a series of SKNodes to represent the pixels,
        // and save them in the grid for future reference
        for row in 0..<numRows {
            // Swift 2D arrays are dumb, you have to create a row thus...
            grid.append([])

            for col in 0..<numColumns {
                // make a new node and set it to the background color
                let n = SKSpriteNode.init(color: SKColor.black, size:CGSize(width: pixelSize, height: pixelSize))
                
                // our screen is -size.width/2...size.width/2, the original is numColumns, so convert
                let xloc = pixelSize * Double(col - (numColumns / 2)) + (pixelSize / 2)
                let yloc = pixelSize * Double(row - (numRows / 2)) + (pixelSize / 2)
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
        // select new X and Y locations, which happens every loop
        // the &+ means "add and roll over, don't report overflow"
        let newY = Y &+ ((X >> 2) & mask)
        let newX = X &- ((newY >> 2) & mask)

        // convert the Dazzler color number to an SKColor
        var newC = colormap[color]!
        
        // if it's and odd loop, force it to black
        if loop % 2 == 0 {
            newC = SKColor.black
        }
        
        // the values in the original code are 0..255, which has to do with the
        // way the Dazzler arranged memory. So here we convert to 0..31
        // these need to be Int to access the dictionary
        let ourX = Int(newX) / 8
        let ourY = Int(newY) / 8

        // now we can update the four pixels with the new color, the x and y values
        grid[ourX + 32][ourY + 32].color = newC     // lower right
        grid[32 - ourX][ourY + 32].color = newC     // lower left
        grid[32 - ourX][32 - ourY].color = newC     // upper left
        grid[ourX + 32][32 - ourY].color = newC     // upper right

        // now our new X and Y become the old X and Y
        X = newX
        Y = newY
        
        // see if this is the 64th loop, and update if it is
        loop -= 1
        if loop == 0 {
            // reset it
            loop = 63
            
            // bump X and Y
            X &+= 1
            Y &+= 1

            color -= 1  // change the color
            // if that made it black...
            if color == 0 {
                color = 15  // reset it
                mask &+= 1   // and change the mask
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // replaced by the Timer above
        // updateKalidescope()
    }
}
