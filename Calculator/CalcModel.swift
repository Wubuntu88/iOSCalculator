//
//  CalcModel.swift
//  Calculator
//
//  Created by William Edward Gillespie on 8/13/15.
//  Copyright (c) 2015 William Edward Gillespie. All rights reserved.
//

import Foundation

class CalcModel
{
    private var operandStack = [Value]()
    
    private var knownOps = [String: Operation]()
    private var knownConstants = [String: Double]()
    
    private enum Operation: CustomStringConvertible{
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private enum Value {
        case Number(Double)
        case Constant(String)
        
        func doubleValue(KnownConstants constants: [String:Double]) -> Double {
            switch self {
            case .Number(let num):
                return num
            case .Constant(let symbol):
                return constants[symbol]!
            }
        }
        
    }
    
    init(stack: [Double]) {
        func learnOp(op: Operation) {
            knownOps[op.description] = op
        }
        learnOp(Operation.BinaryOperation("×", *))
        learnOp(Operation.BinaryOperation("÷", { $1 / $0 }))
        learnOp(Operation.BinaryOperation("+", +))
        learnOp(Operation.BinaryOperation("−", { $1 - $0 }))
        learnOp(Operation.UnaryOperation("√", sqrt))
        learnOp(Operation.UnaryOperation("sin", sin))
        learnOp(Operation.UnaryOperation("cos", cos))
        
        knownConstants["π"] = M_PI //pi 3.14159
        knownConstants["e"] = M_E  //e: 2.7...
        
        for (_, value) in stack.enumerate() {
            operandStack.append(Value.Number(value))
        }
        print(operandStack)
    }
    
    private func evaluate(operation: Operation) -> Double? {
        switch operation {
        case .UnaryOperation(_, let function):
            let lastIndex = operandStack.count - 1
            let value = operandStack[lastIndex].doubleValue(KnownConstants: knownConstants)
            let result = function(value)
            operandStack[lastIndex] = Value.Number(result)
            return result
        case .BinaryOperation(_, let function):
            let lastIndex = operandStack.count - 1
            let nextToLastIndex = lastIndex - 1
            
            //must get operand 1 and 2 so I can
            let value1 = operandStack[lastIndex].doubleValue(KnownConstants: knownConstants)
            let value2 = operandStack[nextToLastIndex].doubleValue(KnownConstants: knownConstants)
            
            let result = function(value1, value2)
            operandStack[lastIndex] = Value.Number(result)
            for var index = nextToLastIndex; index >= 0; index -= 1 {
                if index != 0 {
                    operandStack[index] = operandStack[index - 1]
                }else {
                    operandStack[0] = Value.Number(1.0)
                }
            }
            print("Stack: \(operandStack)")
            return result
        }
    }
    
    func pushOperand(operand: String) {
        for (index, _) in operandStack.enumerate() {
            if index > 0 {
                operandStack[index - 1] = operandStack[index]
            }
        }
        if knownOps.indexForKey(operand) != nil {//operand is constant
            operandStack[operandStack.count - 1] = Value.Constant(operand)
        }else {//operand is literal numbers
            operandStack[operandStack.count - 1] = Value.Number(NSNumberFormatter().numberFromString(operand)!.doubleValue)
        }
        print("Stack: \(operandStack)")
    }
    
    func performOperation(symbol: String) -> Bool {
        if let function = knownOps[symbol] {
            evaluate(function)
            return true
        }
        return false//unsuccessful if operation symbol is unknown
    }
    
    func clearTopRegister() {
        operandStack[operandStack.count - 1] = Value.Number(0.0)
    }
    
    func rollDown() {
        let topval = operandStack.removeLast()
        operandStack.insert(topval, atIndex: 0)
    }

    func operandStackDescription() -> [String] {
        return operandStack.map({
            (number) -> String in
            switch number {
            case .Number(let doubleValue):
                return "\(doubleValue)"
            case .Constant(let symbol):
                return symbol
            }
        })
    }
    
    internal func constants() -> [String: Double] {
        return knownConstants
    }
    
}