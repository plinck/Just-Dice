//
//  Dice.swift
//  Just Dice
//
//  Created by Paul Linck on 10/30/18.
//  Copyright © 2018 Paul Linck. All rights reserved.
//

import UIKit

// This class has all the informaton for one dice
class Dice {
    
    static var imageFaces: Array<UIImage> = []      // should just be one array for all dice
    
    var diceIndexValue : Int = 0                  // 0-5 == 1-6
    var diceCurrentValue : Int = 1                // 1-6
    var imageView : UIImageView

    // MARK: -
    // Initializes dice
    init(imageView: UIImageView) {
        self.imageView = imageView
        
        Dice.imageFaces = createImageFaceArray(total: 6, imagePrefix: "dice")
    }
    
    // MARK: -
    // Build the list of images faces for the dice
    // using the assets in xcassets
    func createImageFaceArray(total: Int, imagePrefix: String) -> [UIImage] {
        var imageFaceArray: [UIImage] = []
        
        for imageCount in 0..<total {
            let imageNbr = imageCount + 1           // since images are names 1-6 vs 0-5
            let imageName = "\(imagePrefix)\(imageNbr).png"
            let image = UIImage(named: imageName)!
            imageFaceArray.append(image)
        }
        
        return imageFaceArray
    }
    
    // MARK: - Randomize the value of a di
    func randomize() {
        diceIndexValue = Int.random(in: 0...5)
        diceCurrentValue = diceIndexValue + 1
    }
    
    // MARK: - Return the current face for di
    func imageFace() -> UIImage {
        return Dice.imageFaces[diceIndexValue]
    }

}
