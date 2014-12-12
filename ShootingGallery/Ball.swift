//
//  Ball.swift
//  ShootingGallery
//
//  Created by Steven Shatz on 9/8/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

import UIKit
import AVFoundation


class Ball: UIView {
    
    var startX: Int!
    var startY: Int!
    var width: Int!
    var height: Int!
    
    var label: UILabel!
    
    var direction: Direction!
    
    var animator: UIDynamicAnimator!        // UIKit's Physics Engine
    
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    var itemBehavior: UIDynamicItemBehavior!
    
    var collisionSoundPath: String?         // AV Audio Player
    var collisionSoundURL: NSURL?
    var collisionSoundPlayer: AVAudioPlayer?
    
    
    init(parentView: UIView!, delegate: UICollisionBehaviorDelegate!) {
        
        // *********************************************
        // * Define all of the Ball class's Properties *
        // *********************************************
        
        self.startX = Int(Float(parentView.frame.minX)) + 1   // start at Col just inside window frame
        self.startY = Int(Float(parentView.frame.minY)) + 1   // start at Row just inside window frame
        
        //startY = 400  // start ball near bottom of screen (for testing final disappearance)
        
        var ballSize: Int = 50
        self.width = ballSize
        self.height = ballSize
        
        var labelX = CGFloat(self.startX)
        var labelY = CGFloat(self.startY)
        var labelWidth = CGFloat(self.width)
        var labelHeight = CGFloat(self.height)
        
        self.direction = Direction()     // This is a CGVector (see: Direction.swift)
        self.direction.reverseBallDirection()
        
        self.animator = UIDynamicAnimator()
        
        self.gravity = UIGravityBehavior()
        self.collision = UICollisionBehavior()
        self.itemBehavior = UIDynamicItemBehavior()
        
        self.collisionSoundPath = nil
        self.collisionSoundURL = nil
        self.collisionSoundPlayer = nil
        
        // **************
        // * Super Init *
        // **************
        
        // Now that all Ball properties have been init'ed, we can invoke super.init()...
        super.init(frame: CGRect(x: self.startX, y: self.startY, width: ballSize, height: ballSize))
        
        
        // *****************
        // * Rest of Setup *
        // *****************
        
        self.layer.cornerRadius = 25.0
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 0.0    // don't show border
        
        self.backgroundColor = self.genRandomColor()
        //self.backgroundColor = UIColor.grayColor()
        
        self.label = UILabel(frame: CGRectMake(labelX, labelY, labelWidth, labelHeight))
        self.label.textColor = UIColor.blackColor()
        self.label.textAlignment = NSTextAlignment.Center
        self.label.text = ""
        self.addSubview(self.label)
        
        // generate random magnitude
        
        let num = Int(arc4random_uniform(5001))     // returns Int between 0 and 5000
        var flt = (CGFloat(num) / 1000.0) + 0.01    // converts Int to CGFloat between 0.000 to 5.000
        
        self.gravity.magnitude = flt        // Magnitude: speed of gravity - smaller CGFloat numbers are slower; negative nums reverse direction; 0.01 to 5.00
        self.gravity.gravityDirection = self.direction.currentDirection
        
        self.collision.collisionMode = UICollisionBehaviorMode.Everything
        self.collision.collisionDelegate = delegate

        self.itemBehavior.allowsRotation = true
        self.itemBehavior.angularResistance = -4.0  // make the ball spin -- reset to 0.0 to stop spin
        self.itemBehavior.elasticity = 0.0          // ranges from 0.0 to 1.0
        self.itemBehavior.friction = 0.0
        self.itemBehavior.resistance = 0.0
        self.itemBehavior.density = 10000.0

        self.gravity.addItem(self)
        self.collision.addItem(self)
        self.itemBehavior.addItem(self)
        
        self.collisionSoundPath = NSBundle.mainBundle().pathForResource("blip", ofType: "wav")
        self.collisionSoundURL = NSURL(fileURLWithPath: collisionSoundPath!)
        self.collisionSoundPlayer = AVAudioPlayer(contentsOfURL: collisionSoundURL, error: nil)
        self.collisionSoundPlayer!.enableRate = true
        self.collisionSoundPlayer!.prepareToPlay()
        self.collisionSoundPlayer!.rate = 1.4
        
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
