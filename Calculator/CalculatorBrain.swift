//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Matthew Fitzpatrick on 3/7/15.
//  Copyright (c) 2015 Ceryni. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                        return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    func clear() {
        self.opStack = [Op]()
    }
    
    init() {
        knownOps["*"] = Op.BinaryOperation("*", *)
        knownOps["/"] = Op.BinaryOperation("/", {$1 / $0})
        knownOps["-"] = Op.BinaryOperation("-", {$1 - $0})
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, rest: [Op]) {
        println("Evaluating Ops: \(ops)")
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                println("Operand: \(operand)")
                return (operand, remainingOps)
            case .UnaryOperation(let symbol, let operation):
                println("UnaryOperation: \(symbol)")
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.rest)
                }
            case .BinaryOperation(let symbol, let operation):
                println("BinaryOperation: \(symbol)")
                let op1Eval = evaluate(remainingOps)
                if let op1 = op1Eval.result {
                    let op2Eval = evaluate(op1Eval.rest)
                    if let op2 = op2Eval.result {
                        return (operation(op1, op2), op2Eval.rest)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}
