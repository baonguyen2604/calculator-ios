//
//  ViewController.swift
//  Calculator
//
//  Created by Bao Nguyen on 9/11/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var previousOps: UILabel!
    
    private var userTyping = false
    
    private var previousText = ""
    
    private var lastDigit = ""
    
    @IBAction func clear(_ sender: UIButton) {
        previousText = ""
        lastDigit = ""
        userTyping = false
        display!.text = "0"
        previousOps!.text = " "
        processor.clear()
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userTyping {
            let textInDisplay = display.text!
            if (!digit.contains(".") || !display.text!.contains(".")) {
                display!.text = textInDisplay + digit
            }
        } else {
            display.text = digit
            userTyping = true
        }
        lastDigit = digit
        
        if !processor.resultIsPending && !userTyping {
            previousOps!.text = lastDigit
        } else if userTyping && !processor.resultIsPending {
            previousText = ""
        }
        
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var processor = Processor()

    @IBAction func performOperation(_ sender: UIButton) {
        if userTyping {
            processor.setOperand(displayValue)
            userTyping = false
        }
        if let mathSymbol = sender.currentTitle {
            processor.performOperations(mathSymbol)
            previousText = processor.computePrevText(&previousText, mathSymbol, &lastDigit)
            if processor.resultIsPending {
                previousOps!.text = previousText + " ..."
            } else {
                previousOps!.text = previousText + " = "
            }
        }
        if let result = processor.result {
            displayValue = result
        }
    }
    
}

