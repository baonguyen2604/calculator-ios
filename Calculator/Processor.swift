//
//  Processor.swift
//  Calculator
//
//  Created by Bao Nguyen on 9/12/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import Foundation

struct Processor {
    
    var resultIsPending: Bool {
        return evaluate().isPending
    }
    
    var result: Double? {
        return evaluate().result
    }
    
    var description: String? {
        return evaluate().description
    }
    
    private enum Ops {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) ->String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private enum Input {
        case operand(Double)
        case operation(String)
        case variable(String)
    }
    
    private var stack = [Input]()
    
    private var operations: Dictionary<String,Ops> = [
        "π" : Ops.constant(Double.pi),
        "e" : Ops.constant(M_E),
        
        "√" : Ops.unaryOperation(sqrt, { "√(" + $0 + ")" }),
        "cos" : Ops.unaryOperation(cos, { "cos(" + $0 + ")" }),
        "sin" : Ops.unaryOperation(sin, { "sin(" + $0 + ")" }),
        "tan" : Ops.unaryOperation(tan, { "tan(" + $0 + ")" }),
        "ln" : Ops.unaryOperation(log, { "ln(" + $0 + ")"}),
        "±" : Ops.unaryOperation({ -$0 }, { "-(" + $0 + ")" }),
        
        "x" : Ops.binaryOperation(*, {$0 + " x " + $1}),
        "÷" : Ops.binaryOperation(/, {$0 + " ÷ " + $1}),
        "+" : Ops.binaryOperation(+, {$0 + " + " + $1}),
        "−" : Ops.binaryOperation(-, {$0 + " - " + $1}),
        
        "=" : Ops.equals
    ]
    
    mutating func performOperations(_ symbol: String) {
        stack.append(Input.operation(symbol))
    }
    
    mutating func setOperand(_ operand: Double) {
        stack.append(Input.operand(operand))
    }
    
    mutating func setOperand(variable named:String) {
        stack.append(Input.variable(named))
    }
    
    mutating func clear() {
        stack.removeAll()
    }
    
    mutating func undo() {
        if (!stack.isEmpty) {
            stack.removeLast()
        }
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        var accumulator: (Double, String)?
        
        struct pendingBinOp {
            let function: (Double, Double) -> Double
            let description: (String, String) -> String
            let firstOp: (Double, String)
            
            func perform(with secondOp: (Double, String)) -> (Double, String) {
                return (function(firstOp.0, secondOp.0), description(firstOp.1, secondOp.1))
            }
        }
        
        var pending: pendingBinOp?
        
        func performPendingBinOp() {
            if pending != nil && accumulator != nil {
                accumulator = pending!.perform(with: accumulator!)
                pending = nil
            }
        }
        
        var result: Double? {
            if accumulator != nil {
                return accumulator!.0
            }
            return nil
        }
        
        var description: String? {
            if pending != nil {
                return pending!.description((pending?.firstOp.1)!, accumulator?.1 ?? "")
            }
            return accumulator?.1
        }
        
        for element in stack {
            switch element {
            case .operand(let value):
                accumulator = (value, "\(value)")
            case .operation(let symbol):
                if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value):
                        accumulator = (value, symbol)
                        performPendingBinOp()
                    case .unaryOperation(let f, let description):
                        if accumulator != nil {
                            accumulator = (f(accumulator!.0), description(accumulator!.1))
                        }
                    case .binaryOperation(let f, let description):
                        if (pending != nil) {
                            performPendingBinOp()
                        }
                        if accumulator != nil {
                            pending = pendingBinOp(function: f, description: description, firstOp: accumulator!)
                            accumulator = nil
                        }
                    case .equals:
                        performPendingBinOp()
                        pending = nil
                    }
                }
            case .variable(let variableName):
                if let value = variables?[variableName] {
                    accumulator = (value, variableName)
                } else {
                    accumulator = (0, variableName)
                }
            }
        }
        
        return (result, pending != nil, description ?? "")
        
    }
}
