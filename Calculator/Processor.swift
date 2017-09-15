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
    
    private var resultIsPending: Bool {
        get {
            return pending != nil
        }
    }
    
    private var accumulatorString: String?
    private var description = ""
    
    private struct pendingBinOp {
        let f: (Double, Double) -> Double
        let fistOp: Double
        
        func perform(with secondOp: Double) -> Double {
            return f(fistOp, secondOp)
        }
    }
    
    mutating func performOperations(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                accumulatorString = String(value)
            case .unaryOperation(let f):
                if accumulator != nil {
                    accumulator = f(accumulator!)
                    
                }
                description = "\(symbol)(\(accumulator!))"
            case .binaryOperation(let f):
                if accumulator != nil {
                    pending = pendingBinOp(f: f, fistOp: accumulator!)
                    description = "\(accumulator!) \(f)"
                    accumulator = nil
                }
            case .equals:
                performPendingBinOp()
            }
        }
    }
    
    mutating private func performPendingBinOp() {
        if pending != nil && accumulator != nil {
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
}
