//
//  ViewController.swift
//  ShootingGallery
//
//  Created by Steven Shatz on 9/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation


class ViewController: UIViewController, UICollisionBehaviorDelegate {
        
    // To Do: Figure out how to keep paddle and each ball in its own animator, yet handle paddle/ball collissions ???
    
    // To Do: Add shooting touches with bullets that fire straight upwards from touch point
    //          or add auto shooting from current paddle loc (make bullets go straight Up and vanish at ceiling (on collision)
    // To Do: If bullet collision, drop object rapidly, make bullet vanish immediately
    // To Do: Track hits and misses
    // To Do: End game after x shots
    // To Do: Display score
    // To Do: Display game over
    
    // Another pgm - create large box of smaller boxes. When pgm starts, explode each box off screen in its own direction
    //      if enough boxes, should look like a growing circle
    //             - when small boxes go off screen (at collision, diappear them), init new set of boxes in center and repeat pattern.
    //      Each iteration, randomly set box color (same for all small boxes)
    //  Better: instead of boxes, make pie slices out of a circle. Orient each slice so together they form a big circle
    
    
    var paddle: Paddle!
    
    var newBall: Ball!
    var ballCount: Int = 0
    var launches: Int = 0
    var maxBalls: Int = 10
    
    var minElapsedSecondsBetweenLaunches: Double = 1.0 //2.0
    var timeOfLastLaunch = NSDate()
    
    var randomElasticity: Float = 0.0
    
    var showTrail: Bool = false             // Set to true to show movement trails of ball
    
    var showBallLabel: Bool = true

    var flashOnCollision: Bool = true
    
    var ballWallCollisionCounter: Int = 0
    
    var vanishSoundPlayer: AVAudioPlayer!
    var vanishSoundPath: String!
    var vanishSoundURL: NSURL!
    
    let backgrounds = [
        "colorfulDots.jpg",
        "blueDots.jpg",
        "goldBigDots.jpg",
        "forestgreenBigDots.jpg",
        "rustyBigDots.jpg",
        "lightblueBigDots.jpg",
        "deepgreenBigDots.jpg",
        "maroonBigDots.jpg",
        "lightblueTinyDots.jpg"
    ]
    var backgroundIndex: Int = 0
    
    
    @IBOutlet weak var ballsLaunchedLabel: UILabel!
    @IBOutlet weak var ballsOnScreenLabel: UILabel!
    @IBOutlet weak var bouncesLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: backgrounds[backgroundIndex])!)
        
        launchPaddle()
        
        vanishSoundPath = NSBundle.mainBundle().pathForResource("falling", ofType: "wav")
        vanishSoundURL = NSURL(fileURLWithPath: vanishSoundPath!)
        vanishSoundPlayer = AVAudioPlayer(contentsOfURL: vanishSoundURL, error: nil)
        vanishSoundPlayer.enableRate = true
        vanishSoundPlayer.prepareToPlay()
        vanishSoundPlayer.rate = 1.6
        
        launchNewBall()
    }
    
    
    func launchPaddle() {
        
        paddle = Paddle(parentView: self.view, delegate: self)
        
        view.addSubview(paddle)
        
        paddle.animator = UIDynamicAnimator(referenceView: view)
        
        paddle.collision.translatesReferenceBoundsIntoBoundary = true  // causes boundary to use bounds of the referenceView supplied to UIDynamicAnimator
        
        paddle.animator.addBehavior(paddle.gravity)
        paddle.animator.addBehavior(paddle.collision)
        paddle.animator.addBehavior(paddle.itemBehavior)

    }
 
    
    func launchNewBall() {
        
        // Prevent launching balls too close together
        
        var elapsedSecondsSinceLastLaunch = NSDate().timeIntervalSinceDate(timeOfLastLaunch)    // <<<<< Difference in seconds (double)
        
        if ballCount < 1 { elapsedSecondsSinceLastLaunch = minElapsedSecondsBetweenLaunches }   // force 1st ball when screen is empty
        
//            // Attempt to not lose any balls that are delayed
//            // Did not work: All the delayed balls get launched simultaneously
//        
//            if ballCount > 0 && ballCount < maxBalls {
//                let elapsedSecondsSinceLastLaunch = NSDate().timeIntervalSinceDate(timeOfLastLaunch)     // <<<<< Difference in seconds (Double)
//                if elapsedSecondsSinceLastLaunch >= minElapsedSecondsBetweenLaunches {
//                    let secondsToWait: NSTimeInterval = minElapsedSecondsBetweenLaunches - elapsedSecondsSinceLastLaunch    // Double
//                    let nanosecondsToWait: Double = secondsToWait * Double(NSEC_PER_SEC)
//                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(nanosecondsToWait))
//                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {self.launchNewBall() } )
//                }
//            }
        
        
        if ballCount < maxBalls && elapsedSecondsSinceLastLaunch >= minElapsedSecondsBetweenLaunches {

            newBall = Ball(parentView: self.view, delegate: self)
            
            view.addSubview(newBall)
            
            timeOfLastLaunch = NSDate()                                 // Get current date/time
            
            // Option: Leave trail on screen of ball's movement
            if self.showTrail {
                self.showTrail = false                                  // only enable for 1st ball object created
                var cnt: Int = 0
                newBall.gravity.action = {
                    ++cnt
                    if cnt % 3 == 0 {
                        let outline = UIView(frame: self.newBall.bounds)
                        outline.center = self.newBall.center
                        outline.transform = self.newBall.transform
                        outline.alpha = 0.5                             // for solid boxes, change this to 1.0
                        outline.backgroundColor = UIColor.clearColor()
                        outline.layer.cornerRadius = 25.0
                        outline.layer.borderWidth = 1.0
                        self.view.addSubview(outline)
                    }
                }
            }

            newBall.animator = UIDynamicAnimator(referenceView: view)
            
            newBall.collision.translatesReferenceBoundsIntoBoundary = true  // causes boundary to use bounds of the referenceView supplied to UIDynamicAnimator
            
            // Make sure ball can collide with paddle
            //newBall.collision.addItem(self.paddle)
            
            //println("After adding Paddle to newBall: \(newBall.collision.items)")
            
            newBall.animator.addBehavior(newBall.gravity)
            newBall.animator.addBehavior(newBall.collision)
            newBall.animator.addBehavior(newBall.itemBehavior)

            ++ballCount
            
            //println("Launched ball #\(ballCount)")
            
            ballsOnScreenLabel.text = "Balls on Screen: \(self.ballCount)"
            
            ++launches
            
            if showBallLabel {
                newBall.label.text = " \(launches) "
            }
            
            ballsLaunchedLabel.text = "Balls Launched: \(launches)"
            
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // ***************************************
    // * UICollisionBehaviorDelegate Methods *
    // ***************************************
    
    func collisionBehavior(behavior: UICollisionBehavior!, beganContactForItem item: UIDynamicItem!, withBoundaryIdentifier identifier: NSCopying!, atPoint p: CGPoint) {
        //println("\nStart of collision behavior")
        //println("Collision Boundary contact occurred - \(item); \(identifier)")  // identifier is frame of view (shown as "nil")
        //println("Collision Point: \(p)")
        //println("Collision FrameMaxY: \(view.frame.maxY)")
                
        if item is Paddle {
            let paddle = item as Paddle
            paddleHitWall(paddle)
        }
        
        if item is Ball {
            let ball = item as Ball
            ballHitWall(ball)
        }
        
    }//end of function
    
    
    func paddleHitWall(thePaddle: Paddle) {
        //println("In paddleHitWall")
        //println("collision items: \(thePaddle.collision.items)")

        thePaddle.direction.reversePaddleDirection()
        thePaddle.gravity.gravityDirection = thePaddle.direction.currentDirection
    }
    
    func ballHitWall(theBall: Ball) {
        //println("In ballHitWall")
        //println("collision items: \(theBall.collision.items)")

        theBall.itemBehavior.elasticity = 0.0
        theBall.itemBehavior.friction = 100.0           // Bump these up to slow ball down before changing direction
        theBall.itemBehavior.resistance = 100.0
        
        // Randomly speed up/slow down ball after bouncing off wall
        randomElasticity = Float(arc4random_uniform(UInt32(5))) / 10.0      // float between 0.0 (slow) and 0.6 (fast), inclusive
        theBall.itemBehavior.elasticity = CGFloat(randomElasticity)
        theBall.collisionSoundPlayer!.rate = 1.4 + pow(2, randomElasticity)    // speed up/slow down sound, accordingly
        
        if self.flashOnCollision {
            theBall.collisionSoundPlayer!.play()           // play sound effect
            
            let saveColor = theBall.backgroundColor
            let saveAlpha = theBall.alpha
            theBall.backgroundColor = UIColor.yellowColor()    // Upon hit, make ball yellow ...
            theBall.alpha = 0.05
            UIView.animateWithDuration(0.1) {               // ... then fade it back to original color ...
                theBall.backgroundColor = saveColor            // ... effectively, flashing it
            }
            theBall.alpha = saveAlpha
            
        }
        
        theBall.direction.reverseBallDirection()
        theBall.gravity.gravityDirection = theBall.direction.currentDirection
        
        theBall.itemBehavior.friction = 0.0            // Now reduce them again to speed ball up
        theBall.itemBehavior.resistance = 0.0
        
        //println("theBall.frame.maxY: \(theBall.frame.maxY)")
        //println("self.frame.maxY: \(self.frame.maxY)")
        
        if theBall.frame.maxY >= view.frame.maxY - 50.0 {
            theBall.backgroundColor = UIColor.redColor()    // Just before hitting bottom, turn ball red
        }
        
        //When ball hits bottom, let it drop out of the frame...
        
        if theBall.frame.maxY >= view.frame.maxY - 1.0 {
            //println("Ball touched bottom")
            
            if ballCount <= 5 {
                self.vanishSoundPlayer.play()
                vanishSoundPlayer.rate = 1.6 + pow(2, randomElasticity)        // speed up/slow down sound, accordingly
            }
            
            theBall.direction.dropDown()       // Change direction to Down
            theBall.gravity.gravityDirection = theBall.direction.currentDirection
            theBall.gravity.magnitude *= 5.0   // Speed up the drop
            
            //println("About to remove ball from collision behavior")
            theBall.collision.removeItem(theBall)     // allow ball to fall thru "floor"
            
            //println("Ball about to disappear")
            theBall.gravity.removeItem(theBall)
            theBall.itemBehavior.removeItem(theBall)
            theBall.collision.removeItem(self.paddle)
            theBall.collision.removeAllBoundaries()
            theBall.animator.removeAllBehaviors()
            theBall.removeFromSuperview()
            
            --self.ballCount
            
            ballsOnScreenLabel.text = "Balls on Screen: \(self.ballCount)"
            
            //println("Ball should now be gone from: gravity, collision, itemBehavior, animator, and view; frame should be gone from collision")
            //println("At this point, end of collision delegate will not be called")
            
            launchNewBall()
            
        } //end of when ball hits bottom
        
    } //end of function BallHitWall()
    
    
    
    func collisionBehavior(behavior: UICollisionBehavior!, endedContactForItem item: UIDynamicItem!, withBoundaryIdentifier identifier: NSCopying!) {
        //println("\nEnd of collision behavior")
        //println("Collision Boundary contact is ending - \(item); \(identifier)")  // identifier is frame of view (shown as "nil")
        
        // Release a new ball after every 13 collisions...
        
        ++ballWallCollisionCounter
        
        //println("ballWallCollisionCounter = \(ballWallCollisionCounter)")
        
        bouncesLabel.text = "Bounces: \(ballWallCollisionCounter)"

        
        if ballWallCollisionCounter % 13 == 0 {
            launchNewBall()
        }
        
        if ballWallCollisionCounter % 41 == 0 {
            swapBackground()
        }
        
    }
    
    func swapBackground() {
        ++backgroundIndex
        if backgroundIndex >= backgrounds.count {
            backgroundIndex = 0
        }
        view.backgroundColor = UIColor(patternImage: UIImage(named: backgrounds[backgroundIndex])!)
    }
    
    
    // ***********************************
    // * Delegates for 2 items colliding *
    // ***********************************
    
    func collisionBehavior(behavior: UICollisionBehavior!, beganContactForItem item1: UIDynamicItem!, withItem item2: UIDynamicItem!, atPoint p: CGPoint) {
        println("\nStart of two items collided")
        println("Collision Point: \(p)")

        println("Two items collided - \(item1); \(item2)")
        
        if item1 is Ball && item2 is Paddle {       // if ball hits paddle
            let ball = item1 as Ball
            let thePaddle = item2 as Paddle
            
            thePaddle.paddleHitSoundPlayer!.play()  // play sound effect

            ball.direction.flyUp()                  // Change direction to Up
            ball.gravity.gravityDirection = ball.direction.currentDirection
            ball.gravity.magnitude *= 5.0           // Speed up
            return
        }
        
        if item1 is Paddle && item2 is Ball {      // if ball hits paddle
            let ball = item2 as Ball
            let thePaddle = item1 as Paddle
            
            thePaddle.paddleHitSoundPlayer!.play()  // play sound effect
            
            ball.direction.flyUp()                  // Change direction to Up
            ball.gravity.gravityDirection = ball.direction.currentDirection
            ball.gravity.magnitude *= 3.0           // Speed up
            return
        }

    }
    
    func collisionBehavior(behavior: UICollisionBehavior!, endedContactForItem item1: UIDynamicItem!, withItem item2: UIDynamicItem!) {
        //println("End of two items collided")
}


    
}

