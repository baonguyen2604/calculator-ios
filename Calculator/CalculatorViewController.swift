//
//  ViewController.swift
//  Calculator
//
//  Created by Bao Nguyen on 9/11/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var previousOps: UILabel!
    
    @IBOutlet weak var M_Display: UILabel!
    
    private var userTyping = false
    
    private var mDict: Dictionary<String, Double>?
    
    private var functionName: String?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (!processor.evaluate().isPending) {
            var desViewController = segue.destination
            if let navigationController = desViewController as? UINavigationController {
                desViewController = navigationController.visibleViewController ?? desViewController
            }
            
            if let graphVC = desViewController as? GraphViewController{
                graphVC.navigationItem.title = processor.evaluate().description
                graphVC.function = {
                    (x: Double) -> Double? in
                    return self.processor.evaluate(using: ["M": x]).result
                }
            }
        }
    }
    
    @IBAction func setM(_ sender: UIButton) {
        if let value = Double (display!.text!) {
            mDict = [
                "M": value
            ]
        }
        if let result = processor.evaluate(using: mDict).result {
            displayValue = result
        }
        M_Display!.text = "M =  \(mDict!["M"] ?? 0)"
        userTyping = false
    }

    @IBAction func getM(_ sender: UIButton) {
        processor.setOperand(variable: "M")
        if let result = processor.evaluate(using: mDict).result {
            displayValue = result
        }
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

    @IBAction func clear(_ sender: UIButton) {
        userTyping = false
        display!.text = "0"
        previousOps!.text = " "
        M_Display!.text = " "
        mDict?.removeAll()
        processor.clear()
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if userTyping {
            var cur = display!.text
            cur?.removeLast(1)
            display!.text = cur
        } else {
            processor.undo()
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userTyping {
            processor.setOperand(displayValue)
            userTyping = false
        }
        if let mathSymbol = sender.currentTitle {
            processor.performOperations(mathSymbol)
        }
        if let result = processor.evaluate(using: mDict).result {
            displayValue = result
        }
        
        if (processor.evaluate().isPending) {
            previousOps!.text = processor.evaluate(using: mDict).description + "..."
        } else {
            previousOps!.text = processor.evaluate(using: mDict).description + " = "
        }
    }
}

