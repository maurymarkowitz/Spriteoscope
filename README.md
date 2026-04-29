# Spriteoscope

Swift+SpriteKit implementation of the classic Kaleidoscope demo for the Cromemco Dazzler graphics card

**Copyright © 2022 Maury Markowitz**

![MIT license](https://img.shields.io/github/license/maurymarkowitz/Spriteoscope)

Kaleidoscope was among the earliest bits of microcomputer demoware. It was written in only 127 bytes of Intel 8080 code, driving the Cromemco Dazzler, the world's first graphics card. Even today the result is somewhat mesmerizing, so imagine what it was like in 1976. One was set up in a window in NYC and caused a traffic jam on 5th Avenue. The cops had to call the store owner to come and unplug it.

The Dazzler had an odd layout for the framebuffer memory which split the screen into four quadrants. Kaleidoscope took advantage of this to produce 4-way symmetry. As the machine lacked any easy way to produce random numbers, the code uses numbers which are shifted and bitmasked to produce a pseudo-random output. The mask is changed every 64 draws, which results in the periodic "jumps" you see in the pattern.

Loop speed
----------

The original 8080 code runs in a tight loop with no display synchronization. Each inner iteration of the main loop takes approximately 892 clock cycles. On a 2 MHz Altair 8800 that would produce about 2,220 loops per second, on a 4 MHz Z80 it would reach about 4,480.

Since SpriteKit would normally cap the updates at 60 fps, the simulation runs in its own loop outside the main display loop. This `loopspersecond` constant is set to 2,250 to approximate a 2 MHz Altair 8800.

The code
--------
This code is a modified version of Apple's GameKit template you get when you select a game project in Xcode. All of the logic is found in `SpriteoscopeScene.swift`. It consists of two main methods, `setupKalidescope` that is called from the standard `didMove(to:)`, and the main work method in `updateKalidescope`. The code tries to look at much like the original as possible otherwise.

The original Xcode template uses `SKShapeNode` for drawing, which resulted in terrible performance on the order of 2 fps. Replacing this with `SKSpriteNode` immediately improves it to >60 fps. This seems to suggest ShapeNode is re-drawing every sprite whether or not it changed. In contrast, SpriteNode is definitely only updating those that *did* change, in this case their `color`. Also note the annoying syntax for setting up a 2D array in Swift (ugh) and the use of the totally non-obvious boundless operators, like `X &+= 1`.
