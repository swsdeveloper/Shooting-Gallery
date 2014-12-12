//
//  Direction.swift
//  ShootingGallery
//
//  Created by Steven Shatz on 9/8/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

import Foundation
import UIKit

class Direction {
    
    var currentDirection: CGVector
    
    init() {
        self.currentDirection = Direction.None.cgvector
    }

    enum Direction: Int, Printable {
        case None = 0
        case Right, Left, Up, Down, RightDown, LeftDown    // 1, 2, 3, 4, 5, 6
        
        var cgvector: CGVector {
            switch(self) {
            case .None:
                return CGVectorMake(0.0, 0.0)
            case .Right:
                return CGVectorMake(1.0, 0.0)
            case .Left:
                return CGVectorMake(-1.0, 0.0)
            case .Up:
                return CGVectorMake(0.0, -1.0)
            case .Down:
                return CGVectorMake(0.0, 1.0)
            case .RightDown:
                return CGVectorMake(1.0, 0.01)
            case .LeftDown:
                return CGVectorMake(-1.0, 0.01)
            }
        }
             
        static func directionToVector(direction: Direction) -> CGVector {
            return direction.cgvector
        }

        var description: String {
            switch(self) {
            case .None: return "No direction"
            case .Right: return "Right"
            case .Left: return "Left"
            case .Up: return "Up"
            case .Down: return "Down"
            case .RightDown: return "Right in a Downwards direction"
            case .LeftDown: return "Left in a Downwards direction"
            }
        }
    }//end of enum
    
    
    func vectorToDirection(vector: CGVector) -> Direction {
        switch(vector) {
        case CGVectorMake(0.0, 0.0): return Direction.None
        case CGVectorMake(1.0, 0.0): return Direction.Right
        case CGVectorMake(-1.0, 0.0): return Direction.Left
        case CGVectorMake(0.0, -1.0): return Direction.Up
        case CGVectorMake(0.0, 1.0): return Direction.Down
        case CGVectorMake(1.0, 0.01): return Direction.RightDown
        case CGVectorMake(-1.0, 0.01): return Direction.LeftDown
        default: return Direction.None
        }
    }
    
    func reverseBallDirection() {                                       // Reverse self.currentDirection Rd->Ld or Ld->Rd (or None->Rd)
        if self.currentDirection == Direction.RightDown.cgvector {
            self.currentDirection = Direction.LeftDown.cgvector
        } else {
            self.currentDirection = Direction.RightDown.cgvector
        }
        let newDirection: Direction = vectorToDirection(self.currentDirection)
        //println(newDirection.description)
    }
    
    func reversePaddleDirection() {                                       // Reverse self.currentDirection R->L or L->R (or None->R)
        if self.currentDirection == Direction.Right.cgvector {
            self.currentDirection = Direction.Left.cgvector
        } else {
            self.currentDirection = Direction.Right.cgvector
        }
        let newDirection: Direction = vectorToDirection(self.currentDirection)
        //println(newDirection.description)
    }

    func dropDown() {
        self.currentDirection = Direction.Down.cgvector
        let newDirection: Direction = vectorToDirection(self.currentDirection)
        //println(newDirection.description)
    }
    
    func flyUp() {
        self.currentDirection = Direction.Up.cgvector
        let newDirection: Direction = vectorToDirection(self.currentDirection)
        //println(newDirection.description)
    }

    
}


