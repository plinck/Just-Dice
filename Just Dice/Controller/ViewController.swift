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
    let widthEdgeAdjustment: CGFloat = 12.0                 // Keep away from edge of view
    let heightEdgeAdjustment: CGFloat = 8.0                 // Keep away from edge of view
    let defaultDiceSize: CGFloat = 120.0

    var transparentDiceMode = false
    var player: AVAudioPlayer?
    
    var dice : [Dice] = []          // Collection of all the dice
    let rollViewTag = 100           // This is the tag so I can find the Roll View for placing the dice
    var rollView = UIView()         // The rollView to keep dice in
    var pickerData: [String] = ["1", "2", "3", "4", "5", "6", "7"]
    var selectedNbrDice: Int = 2    // Number of dice picked to roll
    
    @IBOutlet weak var numberDiceTexField: UITextField!
    @IBOutlet weak var diceImageView1: UIImageView!
    @IBOutlet weak var diceImageView2: UIImageView!
    @IBOutlet weak var rollBtn: UIButton!
    @IBOutlet weak var seeThruBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round corners of Play Button
        rollBtn.layer.cornerRadius = 6
        seeThruBtn.layer.cornerRadius = 6
        seeThruBtn.setTitle("Hide Dice", for: .normal)
        seeThruBtn.setImage(UIImage(named: "Make Invisible.png"), for: .normal)
        rollBtn.setImage(UIImage(named: "Alt Roll.png"), for: .normal)
        rollBtn.setImage(UIImage(named: "Roll Button Down.png"), for: .highlighted)
        rollBtn.setImage(UIImage(named: "Roll Button Down.png"), for: .focused)
        rollBtn.setImage(UIImage(named: "Roll Button Down.png"), for: .selected)

        guard let myRollView =  view.viewWithTag(rollViewTag) else {
            print("Fatal Error, Cant find Roll View with tag:\(rollViewTag)")
            return
        }
        rollView = myRollView
        
        // Get ride of th storyboard imageViews - just for design
        diceImageView1.removeFromSuperview()
        diceImageView2.removeFromSuperview()
        diceImageView1 = nil
        diceImageView2 = nil

        createPicker()
        createToolbar()
        selectedNbrDice = 2
     }
    
    // Dont do geometry related things in viewDidLoad
    // You should not initialise UI geometry-related things in viewDidLoad,
    // because the geometry of your view is not set at this point and the results will be unpredictable.
    override func viewDidAppear(_ animated: Bool) {
        createDice(selectedNbrDice)                 // Create the dice to roll
        moveDiceToOrigin()                          // Make sure they are in proper spot relative to parent view
    }
    
    // Make dice transparent or opaque
    @IBAction func seeThruBtn(_ sender: Any) {
        if transparentDiceMode == false {
            transparentDiceMode = true
            for i in 0..<dice.count {
                dice[i].imageView.alpha = 0.3
            }
            seeThruBtn.setTitle("Show Dice", for: .normal)
            seeThruBtn.setImage(UIImage(named: "Make Opaque.png"), for: .normal)
        } else {
            transparentDiceMode = false
            for i in 0..<dice.count {
                dice[i].imageView.alpha = 1.0
            }
            seeThruBtn.setTitle("Hide Dice", for: .normal)
            seeThruBtn.setImage(UIImage(named: "Make Invisible.png"), for: .normal)
        }
    }
    
    @IBAction func seeThruMakeOpaque(_ sender: Any) {
        for i in 0..<dice.count {
            dice[i].imageView.alpha = 1.0
        }
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
    // create all the dice
    func createDice(_ numberOfDice: Int) {
        // Get rid of the imageViews first
        for i in 0..<dice.count {
            dice[i].imageView.removeFromSuperview()  // this removes it from your view hierarchy
            // dice[i].imageView = nil;       // If it was a strong reference, make sure to `nil`
        }
        
        // clear dice first
        dice.removeAll()

        for _ in 0..<numberOfDice {
            // Create a UIView with an image for every dice created
            let imageView = UIImageView()
            
            imageView.image = UIImage(named:"dice6")
            imageView.frame.size = CGSize(width: defaultDiceSize, height: defaultDiceSize)
            
            let idice = Dice(imageView: imageView)
            self.rollView.addSubview(imageView)
            
            idice.makeCorrectSize(containerView: rollView, maximumWidth: defaultDiceSize, totalDice: numberOfDice)
            self.dice.append(idice)
            
           }
    }
    
    // MARK: -
    // roll the dice, randomize each one and select the correct face based on that
    func pickImages() {
        
        moveDiceToOrigin()                  // put back to start for the roll to begin
        
        // TODO: - Figure out how to get this working, it was giving gobs of weird errors
        self.playSound()
        
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
        
        // This rotates and changes the size of the view that contains the image
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
                self.dice[i].imageView.frame.origin.y = 8       // animate to top of super view
                let lastX = Int(self.rollView.frame.width - self.dice[i].imageView.frame.width)
                let xPos = CGFloat(Int.random(in: Int(self.widthEdgeAdjustment)..<lastX))
                self.dice[i].imageView.frame.origin.x = xPos   // animate random x
            }
        }) {_ in                                               // Wait until first animae completes, then do this
            
            // For now, these move to random y spots but fixed x to ensure no overlap
            // that needs to be fixed, but i need to think about it more first
            let halfwayY = (self.rollView.frame.height / 2)
            var currentDiceX: CGFloat = 12.0                     // position of x axis
            UIView.animate(withDuration: (animateDuration / 2.0), animations: {     // After up, move down
                () -> Void in
                for i in 0..<self.dice.count {
                    self.dice[i].imageView.frame.origin.y = CGFloat(Int.random(in: 50...Int(halfwayY)))
                    self.dice[i].imageView.frame.origin.x = currentDiceX
                    currentDiceX += (self.dice[i].imageView.frame.width + self.widthEdgeAdjustment)      // move over die
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
        let diceHeight = dice[0].imageView.frame.height
        let parentViewBottomY = self.rollView.frame.height           // Bottom of the view they are contained in
        
        var currentDiceX: CGFloat = 12.0
        for i in 0..<self.dice.count {
            self.dice[i].imageView.frame.origin.y = parentViewBottomY - (diceHeight + self.heightEdgeAdjustment)     //by di height
            self.dice[i].imageView.frame.origin.x = currentDiceX
            currentDiceX += (self.dice[i].imageView.frame.width + self.widthEdgeAdjustment)   // move over di width
        }
    }
    
}  // Class

// MARK: - playsound
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

// MARK: -
// PickerView - includes toolbar and texfield delegates
// This extension is just for dealign with the picker view that picks how many dice
// It acts kind of like a table view
// This extension must also ensure that the user can not type into the text box -
// they must only use the pickerView to edit the number of dice.  Therefore, I must
// use the delegate method of the text input field to not allow them to change characters in text field
extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    // MARK: -
    // Create the picker view and set the default value
    func createPicker() {
        
        // Dont allow editing in UITextField - only picker view
        self.numberDiceTexField.delegate = self

        let numberDicePickerView = UIPickerView()
        
        // Connect data and delegate
        numberDicePickerView.delegate = self
        numberDicePickerView.dataSource = self
        
        // this makes the picker be the text input method vs typing in it
        // Also must do ??? on story board
        numberDiceTexField.inputView = numberDicePickerView
        
        // Customizations
        numberDicePickerView.backgroundColor = .black
        
        // Set default of 2 dice in picker view
        numberDicePickerView.selectRow(1, inComponent: 0, animated: true)
    }
    
    // Text field delegate - make sure use can not edit insdie the text field - only picker view
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool  {
        self.resignFirstResponder()
        return false
    }

    // MARK: - Create the toolbar
    func createToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Customizations
        toolbar.barTintColor = .black
        toolbar.tintColor = .white
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ViewController.dismissKeyboard))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        numberDiceTexField.inputAccessoryView = toolbar
    }
    
    // get rid of pickerview
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func numberOfComponents(in numberDicePickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ numberDicePickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ numberDicePickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ numberDicePickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let nbrDice = Int(pickerData[row]) {
            selectedNbrDice = nbrDice
            numberDiceTexField.text = String(selectedNbrDice)
            createDice(selectedNbrDice)                                       // Create the dice to roll
            moveDiceToOrigin()   // Make sure they are in proper spot relative to parent view
        } else {
            print("Bad Data, code error")
        }
    }
    
    // Customize each row of the picker view
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel      // The label is each text label in picker view
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Neue", size: 20)
        label.text = pickerData[row]
        
        return label
    }
}
