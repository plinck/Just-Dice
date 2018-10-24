//
//  ViewController.swift
//  Just Dice
//
//  Created by Paul Linck on 10/24/18.
//  Copyright © 2018 Paul Linck. All rights reserved.
//

import UIKit

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
    }
    
    func pickImages() {
        animate(imageView: diceImageView1, images: diceImages)
        randomDiceIndex1 = Int.random(in: 0...5)
        diceImageView1.image = diceImages[randomDiceIndex1]
 
        animate(imageView: diceImageView2, images: diceImages)
        randomDiceIndex2 = Int.random(in: 0...5)
        diceImageView2.image = diceImages[randomDiceIndex2]
    }
}

