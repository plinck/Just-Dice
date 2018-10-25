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
    
    @IBOutlet weak var diceImageView1: UIImageView!
    @IBOutlet weak var diceImageView2: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        imageView.animationImages = images
        imageView.animationDuration = 1.0
        imageView.animationRepeatCount = 1
        imageView.startAnimating()
        
        UIView.animate(withDuration: 1.0, animations: {
            () -> Void in
            let rotation1: Int = Int.random(in: 180...360)
            let rotation2: Int = -rotation1
            
            // Rotate and scale - must use concatention to do multiple transforms
            var tt1 = CGAffineTransform(rotationAngle: CGFloat(rotation1))
            tt1 = tt1.concatenating(CGAffineTransform(scaleX: 5, y: 5))
            self.diceImageView1.transform = tt1
            
            var tt2 = CGAffineTransform(rotationAngle: CGFloat(rotation2))
            tt2 = tt2.concatenating(CGAffineTransform(scaleX: 2.0, y: 2.0))
            self.diceImageView2.transform = tt2

        })
    }
    
    func resetAnimate() {
        self.diceImageView1.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        self.diceImageView2.transform = CGAffineTransform(rotationAngle: CGFloat(0))

    }
    
    func pickImages() {
        
        self.playSound()
        animate(imageView: diceImageView1, images: diceImages)
        randomDiceIndex1 = Int.random(in: 0...5)
        diceImageView1.image = diceImages[randomDiceIndex1]
 
        animate(imageView: diceImageView2, images: diceImages)
        randomDiceIndex2 = Int.random(in: 0...5)
        diceImageView2.image = diceImages[randomDiceIndex2]
        
        resetAnimate()
    }
}

// MARK: -
// Added audio in here for now
extension ViewController {
    
    func playSound() {
        var player: AVAudioPlayer?

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
