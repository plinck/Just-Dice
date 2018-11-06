//
//  Dice.swift
//  Just Dice
//
//  Created by Paul Linck on 10/30/18.
//  Copyright © 2018 Paul Linck. All rights reserved.
//
// NOTE: - Dice isnt really a MODEL class since it has a lot of view characteristics
// To be pure, I think I need a true model dice object with data about and then have another diceView
// Object that inherits from it and adds the view and image information.
// For the Dice object to be pure, I should not need UIKit
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
    // This is a STATIC array since all objects of this class share the same set of faces
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
    
    // MARK: -
    // change the size of the dice to ensure they all fit in the superview without touching.
    func makeCorrectSize(containerView: UIView, maximumWidth: CGFloat, totalDice: Int) {
        let parentViewWidth = containerView.frame.width
        let parentViewHeight = containerView.frame.height

        var newWidth: CGFloat = 0.0                        // Make sure all fit with some space
 
        let ratio = imageView.frame.width / imageView.frame.height
        
        if parentViewWidth > parentViewHeight {
            newWidth = parentViewHeight / CGFloat(totalDice) - 12.0
        } else {
            newWidth = parentViewWidth / CGFloat(totalDice) - 12.0
        }
 
        if newWidth > maximumWidth {
            newWidth = maximumWidth                          // Dont want them huge
        }
        if newWidth < 12.0 {
            newWidth = 12.0                          // Dont want them teeny
        }
        let newHeight = newWidth / ratio                    // Its a square so this is not totally necessary
        
        imageView.frame.size = CGSize(width: newWidth, height: newHeight)
    }

}
