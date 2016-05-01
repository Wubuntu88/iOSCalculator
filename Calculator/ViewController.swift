//
//  ViewController.swift
//  Calculator
//
//  Created by William Edward Gillespie on 8/8/15.
//  Copyright (c) 2015 William Edward Gillespie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //@IBOutlet weak var display: UILabel!
    
    
    @IBOutlet weak var topDisplay: UILabel!
    @IBOutlet weak var midDisplay: UILabel!
    @IBOutlet weak var bottomDisplay: UILabel!
    
    
    var calcBrain = CalcModel(stack: [0.0, 0.0, 0.0]) // instantiates model of calculator
    
    /*
        This code is for apedding digits by pressing the numbers
    */
    var userIsCurrentlyTypingInput: Bool = false
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsCurrentlyTypingInput {//user still typing, updates bottom display
            if let displayText = bottomDisplay.text {
                let constants = calcBrain.constants()
                if constants.indexForKey(displayText) == nil {//if it is not a constant (i.e. literal)
                    bottomDisplay.text = bottomDisplay.text! + digit
                }
            }
            
        }else {//user begins typing; move num in midDisplay to topDisplay, then bottomDisplay to midDisplay
            topDisplay.text = midDisplay.text!//topDisplay will never be nil
            midDisplay.text = bottomDisplay.text!//midDisplay will never be nil
            bottomDisplay.text = digit
            bottomDisplay.textColor = UIColor.greenColor()
            userIsCurrentlyTypingInput = true
        }
    }


    @IBAction func InsertConstant(sender: UIButton) {
        let constant = sender.currentTitle!
        if !userIsCurrentlyTypingInput { // if the user is not typing
            topDisplay.text = midDisplay.text!
            midDisplay.text = bottomDisplay.text!
            bottomDisplay.text = constant
            bottomDisplay.textColor = UIColor.greenColor()
            userIsCurrentlyTypingInput = true
        }
    }
    
    @IBAction func appendDecimalPoint() {
        if userIsCurrentlyTypingInput { // user in the middle of typing
            let regex = try? NSRegularExpression(pattern: "[0-9]*\\.?[0-9]", options: [])//"\\d*.\\d*"
            if let regex = regex {
                let displayText = bottomDisplay.text!
                let matches = regex.numberOfMatchesInString(displayText, options: [], range: NSMakeRange(0, displayText.characters.count))
                print(displayText)
                if matches == 1 {
                    print(matches)
                    bottomDisplay.text = bottomDisplay.text! + "."
                }
            }
        } else { // user has pressed enter (or operator); has not started typing next digit
            bottomDisplay.text = "0."
            userIsCurrentlyTypingInput = true
        }
    }
    
    @IBAction func clear() {
        calcBrain.clearTopRegister()
        userIsCurrentlyTypingInput = false
        updateDisplayValues()
    }

    /*
        This code is for the arithmetic operators
    */
    
    @IBAction func operate(sender: UIButton) {
        
        if userIsCurrentlyTypingInput {
            enter()
        }
        if let operation = sender.currentTitle {
            if calcBrain.performOperation(operation) {//need information about type of operator
                updateDisplayValues()
            }
        }
    }
    
    /*
        This code is for when the user hits enter
    */
    @IBAction func enter() {
        let constants = calcBrain.constants()
        if constants.indexForKey(bottomDisplay.text!) != nil {//if it is a constant
            if userIsCurrentlyTypingInput {
                calcBrain.pushOperand(bottomDisplay.text!)
                bottomDisplay.textColor = UIColor.orangeColor()
            }
        }else if let numberFromString = NSNumberFormatter().numberFromString(bottomDisplay.text!) {//must be number
            if userIsCurrentlyTypingInput {//if the user is currently typing, we allow them to "enter"
                calcBrain.pushOperand(numberFromString.stringValue)
                bottomDisplay.textColor = UIColor.orangeColor()
            }
        }else {
            bottomDisplay.text = nil
        }
        userIsCurrentlyTypingInput = false
    }
    
    @IBAction func rollDown() {
        calcBrain.rollDown()
        updateDisplayValues()
    }
    
    @IBAction func back() {
        if userIsCurrentlyTypingInput {
            var displayText = bottomDisplay.text!
            if displayText.characters.count > 1{
                print(displayText)
                let char = displayText.removeAtIndex(displayText.endIndex.predecessor())
                print("char: \(char)")
                print(displayText)
                bottomDisplay.text = displayText
            }else {//count is 1
                bottomDisplay.text = "0"
                userIsCurrentlyTypingInput = false
            }
        }
    }
    
    func updateDisplayValues() {
        let valuesForRegisters = calcBrain.operandStackDescription()
        topDisplay.text = valuesForRegisters[0]
        midDisplay.text = valuesForRegisters[1]
        bottomDisplay.text = valuesForRegisters[2]
    }
}