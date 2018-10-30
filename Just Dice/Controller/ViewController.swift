//
//  ViewController.swift
//  Just Dice
//
//  Created by Paul Linck on 10/24/18.
//  Copyright © 2018 Paul Linck. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var randomDiceIndex1: Int = 0
    var randomDiceIndex2: Int = 0
    
    var transparentDiceMode = false
    
    var player: AVAudioPlayer?
    
    var dice : [Dice] = []                          // Collection of all the dice

    @IBOutlet weak var diceImageView1: UIImageView!
    @IBOutlet weak var diceImageView2: UIImageView!
    @IBOutlet weak var rollBtn: UIButton!
    @IBOutlet weak var seeThruBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round corners of Play Button
        rollBtn.layer.cornerRadius = 6
        seeThruBtn.layer.cornerRadius = 6
        seeThruBtn.setTitle("Make Transparent", for: .normal)
        rollBtn.setImage(UIImage(named: "Roll Button Up.png"), for: .normal)
        rollBtn.setImage(UIImage(named: "Roll Button Down.png"), for: .highlighted)
        rollBtn.setImage(UIImage(named: "Roll Button Down.png"), for: .focused)
        rollBtn.setImage(UIImage(named: "Roll Button Down.png"), for: .selected)

        createDice(2)                                       // Create the dice to roll
        moveDiceToOrigin()   // Make sure they are in proper spot relative to parent view
     }
    
    // Make dice transparent or opaque
    @IBAction func seeThruBtn(_ sender: Any) {
        if transparentDiceMode == false {
            transparentDiceMode = true
            diceImageView1.alpha = 0.4
            diceImageView2.alpha = 0.4
            seeThruBtn.setTitle("Make Opaque", for: .normal)
        } else {
            transparentDiceMode = false
            diceImageView1.alpha = 1.0
            diceImageView2.alpha = 1.0
            seeThruBtn.setTitle("Make Transparent", for: .normal)
        }
    }
    
    @IBAction func seeThruMakeOpaque(_ sender: Any) {
        diceImageView1.alpha = 1.0
        diceImageView2.alpha = 1.0
    }
    
    @IBAction func rollBtn(_ sender: Any) {
        pickImages()
    }
    
    // Change background image while being pressed
    @IBAction func rollBtnPushingDown(_ sender: Any) {
        
    }
    
    // MARK: -
    // Allows shake to roll the dice
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        pickImages()
    }
    
    // MARK: -
    // create the number of dice to use
    func createDice(_ numberOfDice: Int) {
        for i in 0..<numberOfDice {
            // Hack for now.  Need to generate UIImageView(s) for dice images on fly in array
            // And usage the imageView associate with that dice
            var imageView : UIImageView
            
            switch i {
            case 0:
                imageView = diceImageView1
            case 1:
                imageView = diceImageView2
            default:
                imageView = diceImageView1
            }
 
            let myRollAreaView = imageView.superview            // To properly size dice
            let idice = Dice(imageView: imageView)
            idice.makeCorrectSize(parentViewWidth: myRollAreaView!.frame.width, parentViewHeight: myRollAreaView!.frame.width, maximumWidth: 120.0, totalDice: numberOfDice)

            self.dice.append(idice)
        }
    }
    
    // MARK: -
    // roll the dice, randomize each one and select the correct face based on that
    func pickImages() {
        
        moveDiceToOrigin()                  // put back to start for the roll to begin
        
        // TODO: - Figure out how to get this working, it was giving gobs of weird errors
        //self.playSound()
        
        // Move, then animate - since timing is same, the move and animate simultaneously
        moveDice(for: 1.0)                  // Move for 1.0 seconds
        animate(dice, for: 1.0)             // Animate for 1.0 seconds
        
        // This just randomizes the numbers on each dice and picks the correct face
        // It leaves them where they landed for now.
        for i in 0..<dice.count {
            dice[i].randomize()
            dice[i].imageView.image = dice[i].imageFace()
            dice[i].imageView.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        }
    }
    
    // MARK: -
    // Animates an images using the list of images
    func animate(_ dice: [Dice], for animateDuration: Double) {
        
        // This animates through the different images to show dice changing numbers
        // TODO: - Figure out how to combine the face change and the transforms
        // for now they work simultaneuosly since the *animateDuration* is the same
        for i in 0..<dice.count {
            var imageView : UIImageView

            imageView = dice[i].imageView
            imageView.animationImages = Dice.imageFaces          // imageFaces is class level / Static array
            imageView.animationDuration = animateDuration
            imageView.animationRepeatCount = 1
            imageView.startAnimating()
        }
        
        // This rotates and changes the size and moves the view that contains the image
        UIView.animate(withDuration: animateDuration, animations: {
            () -> Void in
            for i in 0..<dice.count {
                var rotation: Int = Int.random(in: 180...360)
                if (i % 2) == 0 {
                    rotation = -rotation
                }
                // Rotate
                var transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
                // Scale - must use concatention to do multiple transforms
                transform = transform.concatenating(CGAffineTransform(scaleX: 5, y: 5))
                dice[i].imageView.transform = transform
            }
        })
    }
    
    // TODO: Currently only works / avoids collision with two dice.
    // MARK: - Move the dice within their parent view
    // Here is the definition of animatiton.  I need to understand better sincd I dont totally get why it works
    // class func animate(withDuration duration: TimeInterval, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil)
    // It appears that the animations are a completion and the is also a completion handler that runs
    // when everything is done.  I know I learned this but forgot.
    func moveDice(for animateDuration: Double) {
        
        // OLD Code
        // let lastValidY = (diceImageView1.superview?.frame.height)! - diceImageView1.frame.height
        // let halfwayX = ((diceImageView1.superview?.frame.width)! / 2)
        // let lastValidX = (diceImageView1.superview?.frame.width)! - diceImageView1.frame.width
        
        // OLD CODE
        // xMoveTo[i] = CGFloat(Int.random(in: 8...Int(halfwayX - diceImageView1.frame.width)))
        // let x2MoveTo = Int.random(in: Int(halfwayX)...Int(lastValidX))
        // self.dice[i].imageView.frame.origin.x = currentDiceX
        
        // Animate them from the bottom to the top, bounce off top, then to random spot near middle
        // want it to animate in half the time for the 1st move and half for the second
        UIView.animate(withDuration: (animateDuration / 2.0), animations: {
            () -> Void in
            for i in 0..<self.dice.count {
                self.dice[i].imageView.frame.origin.y = 1       // animate to top of super view
            }
        }) {_ in                                               // Wait until first animae completes, then do this
            
            // For now, these move to random y spots but fixed x to ensure no overlap
            // that needs to be fixed, but i need to think about it more first
            let halfwayY = ((self.dice[0].imageView.superview?.frame.height)! / 2)
            var currentDiceX: CGFloat = 8.0                     // position of x axis
            UIView.animate(withDuration: (animateDuration / 2.0), animations: {     // After up, move down
                () -> Void in
                for i in 0..<self.dice.count {
                    self.dice[i].imageView.frame.origin.y = CGFloat(Int.random(in: 50...Int(halfwayY)))
                    self.dice[i].imageView.frame.origin.x = currentDiceX
                    currentDiceX += (self.dice[i].imageView.frame.width + 8.0)      // move over die
                }
            }) // animate
        } // - in Completion Handler - i.e. After the first animation is complete
    }
    
    // NOTE: - Only works for two dice.  Need to make sure the dice move and/or get smaller to not roll on
    // top of each other
    // MARK: -
    // NOTE: Very important and took me a whole to figure out.  The frame for the UIImage views
    // -- the dice in this case -- is relatibve to their parent view (i.e. superview).  Therefore,
    // you make you x and y coordinates based on that.  Then if the parent view moves, they move with it.
    // It makes sense but took me forever to figure out.  Also, x,y is from top left corner.  So, y
    // gets bigger as you go down.  So when positioning the dice at the top of the page, you give it
    // a coordinate of like 8 which is 8 from the top of its parent view.  To position back at the bottom
    // you need to get the superviews height and the just subtract the dice height from that to get the
    // proper top coordinate.
    //
    // Move the dice back to their original position just above the bottom of their parent view
    func moveDiceToOrigin() {
        let myRollAreaView = dice[0].imageView.superview
        let diceHeight = dice[0].imageView.frame.height
        let parentViewBottomY = myRollAreaView!.frame.height           // Bottom of the view they are contained in
        
        var currentDiceX: CGFloat = 8.0
        for i in 0..<self.dice.count {
            self.dice[i].imageView.frame.origin.y = parentViewBottomY - (diceHeight)     //off bottom by di height
            self.dice[i].imageView.frame.origin.x = currentDiceX
            currentDiceX += (self.dice[i].imageView.frame.width + 8.0)                    // move over die width
        }
    }
    
}  // Class

// MARK: -
// Added audio in here for now
extension ViewController {
    
    func playSound() {

      guard let soundAsset = NSDataAsset(name: "ShakeRoll") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            // player = try AVAudioPlayer(contentsOf: soundAsset, fileTypeHint: AVFileType.mp3.rawValue)
            player = try AVAudioPlayer(data:soundAsset.data)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            player.volume = 1
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

}
