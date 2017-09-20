//
//  Processor.swift
//  Calculator
//
//  Created by Bao Nguyen on 9/12/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import Foundation

struct Processor {
    
    private var accumulator: Double?
    
    private enum Ops {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    mutating func clear() {
        accumulator = nil
        pending = nil
        description = nil
    }
    
    private var operations: Dictionary<String,Ops> = [
        "π" : Ops.constant(Double.pi),
        "e" : Ops.constant(M_E),
        "√" : Ops.unaryOperation(sqrt),
        "cos" : Ops.unaryOperation(cos),
        "±" : Ops.unaryOperation({ -$0 } ),
        "x" : Ops.binaryOperation(*),
        "÷" : Ops.binaryOperation(/),
        "+" : Ops.binaryOperation(+),
        "−" : Ops.binaryOperation(-),
        "=" : Ops.equals
    ]
    
    private var pending: pendingBinOp?
    
    var resultIsPending: Bool {
        get {
            return pending != nil
        }
    }
    
    var description: String?
    
    private struct pendingBinOp {
        let function: (Double, Double) -> Double
        let firstOp: Double
        
        func perform(with secondOp: Double) -> Double {
            return function(firstOp, secondOp)
        }
    }
    
    mutating func performOperations(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                pending = nil
                description = String(value)
                print(description ?? "")
            case .unaryOperation(let f):
                if accumulator != nil {
                    description = "\(symbol) (\(accumulator!))"
                    accumulator = f(accumulator!)
                    print(description ?? "")
                }
            case .binaryOperation(let f):
                if accumulator != nil {
                    pending = pendingBinOp(function: f, firstOp: accumulator!)
                    description = "\(accumulator!) \(symbol) "
                    accumulator = nil
                }
            case .equals:
                performPendingBinOp()
                print(description ?? "")
                pending = nil
            }
        }
    }
    
    mutating private func performPendingBinOp() {
        if pending != nil && accumulator != nil {
            description! += String(accumulator!)
            accumulator = pending!.perform(with: accumulator!)
            pending = nil
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    func computePrevText(_ UIprevText: inout String, _ symbol: String, _ lastDigit: inout String) -> String {
        if let operation = operations[symbol]{
            switch operation {
            case .constant(_):
                let res = UIprevText
                UIprevText = ""
                return res + " " + symbol
            case .unaryOperation(_):
                let temp = lastDigit
                lastDigit = ""
                if resultIsPending {
                    return UIprevText + " " + symbol + "(" + temp + ")"
                } else {
                    return symbol + "(" + UIprevText + ")"
                }
            case .binaryOperation(_):
                if (UIprevText == "") {
                    UIprevText = lastDigit
                }
                return UIprevText + " " + symbol
            case .equals:
                if lastDigit != "" {
                    UIprevText += " " + lastDigit
                }
                lastDigit = ""
                return UIprevText
            }
        }
        return ""
    }
}
