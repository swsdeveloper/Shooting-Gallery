//
//  Paddle.swift
//  ShootingGallery
//
//  Created by Steven Shatz on 9/9/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

import UIKit
import AVFoundation


class Paddle: UIView {
    
    var startX: Int!
    var startY: Int!
    var width: Int!
    var height: Int!
    
    var direction: Direction!
    
    var animator: UIDynamicAnimator!        // UIKit's Physics Engine
    
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    var itemBehavior: UIDynamicItemBehavior!
    
    var paddleHitSoundPath: String?         // AV Audio Player
    var paddleHitSoundURL: NSURL?
    var paddleHitSoundPlayer: AVAudioPlayer?
    
    
    init(parentView: UIView!, delegate: UICollisionBehaviorDelegate!) {
        
        // ***********************************************
        // * Define all of the Paddle class's Properties *
        // ***********************************************
        
        self.startX = Int(Float(parentView.frame.minX)) + 1   // start at Col just inside window frame
        self.startY = Int(Float(parentView.frame.maxY)) - 20   // start at Row just inside window frame
        
        self.width = 50
        self.height = 10
        
        self.direction = Direction()     // This is a CGVector (see: Direction.swift)
        self.direction.reversePaddleDirection()
        
        self.animator = UIDynamicAnimator()
        
        self.gravity = UIGravityBehavior()
        self.collision = UICollisionBehavior()
        self.itemBehavior = UIDynamicItemBehavior()
        
        self.paddleHitSoundPath = nil
        self.paddleHitSoundURL = nil
        self.paddleHitSoundPlayer = nil
        
        // **************
        // * Super Init *
        // **************
        
        // Now that all Paddle properties have been init'ed, we can invoke super.init()...
        super.init(frame: CGRect(x: self.startX, y: self.startY, width: self.width, height: self.height))
        
        // *****************
        // * Rest of Setup *
        // *****************
        
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 0.0    // don't show border
        
        //self.backgroundColor = self.genRandomColor()
        self.backgroundColor = UIColor.whiteColor()
        
        // generate random magnitude
        
        let num = Int(arc4random_uniform(3001))     // returns Int between 0 and 3000
        var flt = (CGFloat(num) / 1000.0) + 0.01    // converts Int to CGFloat between 0.000 to 3.000
        
        self.gravity.magnitude = flt        // Magnitude: speed of gravity - smaller CGFloat numbers are slower; negative nums reverse direction; 0.01 to 5.00
        self.gravity.gravityDirection = self.direction.currentDirection
        
        self.collision.collisionMode = UICollisionBehaviorMode.Boundaries
        self.collision.collisionDelegate = delegate
        
        self.itemBehavior.allowsRotation = false
        self.itemBehavior.elasticity = 0.0           // ranges from 0.0 to 1.0
        self.itemBehavior.friction = 0.0
        self.itemBehavior.resistance = 10.0         // slow paddle down
        self.itemBehavior.density = 10000.0
        
        self.gravity.addItem(self)
        self.collision.addItem(self)
        self.itemBehavior.addItem(self)
    
        self.paddleHitSoundPath = NSBundle.mainBundle().pathForResource("squish", ofType: "wav")
        self.paddleHitSoundURL = NSURL(fileURLWithPath: paddleHitSoundPath!)
        self.paddleHitSoundPlayer = AVAudioPlayer(contentsOfURL: paddleHitSoundURL, error: nil)
        self.paddleHitSoundPlayer!.enableRate = true
        self.paddleHitSoundPlayer!.prepareToPlay()
        self.paddleHitSoundPlayer!.rate = 1.4
        
    }
 
    // *************************
    // * Generate Random Color *
    // *************************
    
    func genRandomColor() -> UIColor {
        var randomRed:CGFloat =   CGFloat(arc4random_uniform(100000)) / 100000.0    // returns random Double between 0.0 and 1.0, inclusive
        var randomGreen:CGFloat = CGFloat(arc4random_uniform(100000)) / 100000.0
        var randomBlue:CGFloat =  CGFloat(arc4random_uniform(100000)) / 100000.0
//        var randomAlpha:CGFloat = CGFloat(arc4random_uniform(100000)) / 100000.0
//        if randomAlpha == 0.0 {randomAlpha == 0.5}
//        if randomAlpha < 0.5 {randomAlpha += 0.5}
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    // ***********************
    // * Required for UIView *
    // ***********************
    
    required init(coder aDecoder: NSCoder) {
        super.init()
    }
    
}
