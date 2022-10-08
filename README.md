# Spriteoscope
Swift+SpriteKit implementation of the classic Kaleidoscope demo for the Cromemco Dazzler graphics card

**Copyright © 2022 Maury Markowitz**

![MIT license](https://img.shields.io/github/license/maurymarkowitz/Spriteoscope)

Kaleidoscope was among the earliest microcomputer demos. It was written in only 127 bytes of Intel 8080 code, driving the Cromemco Dazzler, the world's first graphics card. Even today the result is somewhat mesmerizing, so imagine what it was like in 1976. One such display was set up in NYC and caused a traffic jam on 5th Avenue that required cops to call the store owner and come and unplug it.

The Dazzler had an odd layout for the framebuffer memory which split the screen into four quadrants, and Kaleidoscope took advantage of this to produce 4-way symmetry. As the machine lacked any easy way to produce random numbers, the code uses large numbers in the registers which are then shifted and bitmasked to produce a pseudo-random output. The mask is changed every 64 draws, which results in the periodic "jumps" you see in the pattern.

This code is a modified version of Apple's GameKit template you get when you select a game project in Xcode. All of the logic is found in `GameScene.swift`. It consists of only two methods, the initial setup in the `didMove(to:)` method, and the main work method in `updateKalidescope` which was originally called from the Scene's `update`, but later moved to a `Timer` for faster updates. The code tries to look at much like the original as possible, which led to some annoyances clamping values down to 0..255. That's when I learned of Swift's *totally non-obvious* boundless operators, like `X = X &+ 1`.

The original template uses `SKShapeNode` for drawing, which resulted in terrible performance on the order of 2 fps. Replacing this with `SKSpriteNode` immediately improves it to >60 fps. This seems to suggest ShapeNode is re-drawing every sprite in the display whether or not it changed. In contrast, SpriteNode is definitely only updating those that *did* change, in this case by changing their `color`. Also note the annoying syntax for setting up a 2D array in Swift... ugh.
