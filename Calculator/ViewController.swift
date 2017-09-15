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
    
    var userTyping = false
    
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
        }
        if let result = processor.result {
            displayValue = result
        }
    }
    
}

