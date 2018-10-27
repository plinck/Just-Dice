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
    
    var diceImages: Array<UIImage> = []
    var randomDiceIndex1: Int = 0
    var randomDiceIndex2: Int = 0
    
    var transparentDiceMode = false
    
    var player: AVAudioPlayer?

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

        moveDiceToOrigin()   // Make sure they are in proper spot relative to parent view

        diceImages = createImageArray(total: 6, imagePrefix: "dice")

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
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        pickImages()
    }
    
    func createImageArray(total: Int, imagePrefix: String) -> [UIImage] {
        var imageArray: [UIImage] = []
        
        for imageCount in 0..<total {
            let imageNbr = imageCount + 1           // since images are names 1-6 vs 0-5
            let imageName = "\(imagePrefix)\(imageNbr).png"
            let image = UIImage(named: imageName)!
            imageArray.append(image)
        }
        
        return imageArray
    }

    // MARK: -
    // Animates an images using the list of images
    func animate(imageView: UIImageView, images: [UIImage]) {
        
        // This animates through the different images to show dice changing numbers
        imageView.animationImages = images
        imageView.animationDuration = 1.0
        imageView.animationRepeatCount = 1
        imageView.startAnimating()
        
        // This rotates and changes the size and moves the view that contains the image
        UIView.animate(withDuration: 1.0, animations: {
            () -> Void in
            let rotation1: Int = Int.random(in: 180...360)
            let rotation2: Int = -rotation1
            
            // Rotate and scale - must use concatention to do multiple transforms
            var tt1 = CGAffineTransform(rotationAngle: CGFloat(rotation1))
            // Scale
            tt1 = tt1.concatenating(CGAffineTransform(scaleX: 5, y: 5))

            self.diceImageView1.transform = tt1
            
            var tt2 = CGAffineTransform(rotationAngle: CGFloat(rotation2))
            tt2 = tt2.concatenating(CGAffineTransform(scaleX: 2.0, y: 2.0))
            self.diceImageView2.transform = tt2

        })
    }
    
    // Put dice back to normal starting position
    func resetAnimate() {
        self.diceImageView1.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        self.diceImageView2.transform = CGAffineTransform(rotationAngle: CGFloat(0))
    }
    
    func pickImages() {
        
        moveDiceToOrigin()
        
        self.playSound()
        
        // Move, then amnimate
        moveDice()
        
        animate(imageView: diceImageView1, images: diceImages)
        randomDiceIndex1 = Int.random(in: 0...5)
        diceImageView1.image = diceImages[randomDiceIndex1]
 
        animate(imageView: diceImageView2, images: diceImages)
        randomDiceIndex2 = Int.random(in: 0...5)
        diceImageView2.image = diceImages[randomDiceIndex2]
        
        resetAnimate()
    }
    
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
        let myRollAreaView = diceImageView1.superview
        let diceHeight = self.diceImageView1.frame.height
        let parentViewBottomY = myRollAreaView!.frame.height           // Bottom of the view they are contained in
        
        
        self.diceImageView1.frame.origin.y = parentViewBottomY - (diceHeight)    // off bottom by di height
        self.diceImageView2.frame.origin.y = parentViewBottomY - (diceHeight)
        self.diceImageView1.frame.origin.x = 32                                  // from left
        self.diceImageView2.frame.origin.x = myRollAreaView!.frame.width - self.diceImageView1.frame.width - 32
    }
    
    // MARK: - Move the dice within their parent view
    // Here is the definition of animatiton.  I need to understand better sincd I dont totally get why it works
    // class func animate(withDuration duration: TimeInterval, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil)
    // It appears that the animations are a completion and the is also a completion handler that runs
    // when everything is done.  I know I learned this but forgot.
    func moveDice() {
        // Setup where the final dice can land making sure they stay on their half
        // of the view so they dont go on top of each other
        let halfwayY = ((diceImageView1.superview?.frame.height)! / 2)
        // let lastValidY = (diceImageView1.superview?.frame.height)! - diceImageView1.frame.height
        let halfwayX = ((diceImageView1.superview?.frame.width)! / 2)
        let lastValidX = (diceImageView1.superview?.frame.width)! - diceImageView1.frame.width
        let y1MoveTo = Int.random(in: 100...Int(halfwayY))
        let y2MoveTo = Int.random(in: 100...Int(halfwayY))
        let x1MoveTo = Int.random(in: 8...Int(halfwayX - diceImageView1.frame.width))
        let x2MoveTo = Int.random(in: Int(halfwayX)...Int(lastValidX))

        // Animate them from the bottom to the top, bounce off top to random spot near middle
        UIView.animate(withDuration: 0.5, animations: {
            () -> Void in
            self.diceImageView1.frame.origin.y = 1    // destination y - bumop the top
            self.diceImageView2.frame.origin.y = 1
        }) {_ in                                        // Explain this, it works but I dont get it
            UIView.animate(withDuration: 0.5, animations: {     // After up move done, move down a little
                () -> Void in
                self.diceImageView1.frame.origin.y = CGFloat(y1MoveTo)       // destination
                self.diceImageView2.frame.origin.y = CGFloat(y2MoveTo)
                self.diceImageView1.frame.origin.x = CGFloat(x1MoveTo)      // destination x
                self.diceImageView2.frame.origin.x = CGFloat(x2MoveTo)
            })
        }
    }
    
}

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
