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
    
    var player: AVAudioPlayer?

    @IBOutlet weak var diceImageView1: UIImageView!
    @IBOutlet weak var diceImageView2: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        moveDiceToOrigin()   // Make sure they are in proper spot relative to parent view

        diceImages = createImageArray(total: 6, imagePrefix: "dice")

    }

     @IBAction func rollBtn(_ sender: Any) {
        pickImages()
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
    }
    
    // MARK: - Move the dice within their parent view
    func moveDice() {
        // Animate them from the bottom to the top of the view
        UIView.animate(withDuration: 1.0, animations: {
            () -> Void in
            self.diceImageView1.frame.origin.y = 8    // destination
            self.diceImageView2.frame.origin.y = 8
        })
    }

}

// MARK: -
// Added audio in here for now
extension ViewController {
    
    func playSound() {

      guard let soundAsset = NSDataAsset(name: "ShakeRoll") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
                        
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            // player = try AVAudioPlayer(contentsOf: soundAsset, fileTypeHint: AVFileType.mp3.rawValue)
            player = try AVAudioPlayer(data:soundAsset.data)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

}
