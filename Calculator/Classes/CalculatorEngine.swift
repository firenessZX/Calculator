//
//  CalculatorEngine.swift
//  Calculator
//
//  Created by 云联 on 2026/5/7.
//

import UIKit

/// 计算器核心引擎
/// 负责将字符串表达式解析并计算结果。
/// 支持运算符：`+`、`-`、`*`、`/`、`%`、`^`
/// 支持一元负号与小数，例如：`-3.5+2*4`
class CalculatorEngine: NSObject {
    
    // 运算符集合：用于判断字符是否为支持的运算符
    let funcArray:Array<String> = ["+","-","*","/","%","^"]
    
    /// 计算表达式结果
    /// - Parameter equation: 输入表达式字符串（可包含空格）
    /// - Returns: 计算结果；当表达式非法或计算失败时返回 `0`
    func caculatEquation(equation:String) -> Double {
        // 去掉表达式中的空格，避免影响解析
        var finalEquation = equation.replacingOccurrences(of: " ", with: "")
        // 空字符串直接返回 0
        if finalEquation.isEmpty {
            return 0
        }
        
        // 如果最后一个字符是运算符（例如 "1+2+"），去掉末尾运算符
        if let last = finalEquation.last, funcArray.contains(String(last)) {
            finalEquation.removeLast()
        }
        
        // 去掉末尾运算符后如果为空，返回 0
        if finalEquation.isEmpty {
            return 0
        }
        
        // 分词：把表达式拆成数字/运算符数组，失败则返回 0
        guard let tokens = tokenize(finalEquation), !tokens.isEmpty else {
            return 0
        }
        
        // 按优先级计算 token，失败则返回 0
        guard let value = evaluateTokens(tokens) else {
            return 0
        }
        
        // 返回最终结果
        return value
    }

    /// 将表达式拆分为 token 数组（数字 / 运算符）
    /// 例如：`-3+2*5` -> `["-3", "+", "2", "*", "5"]`
    private func tokenize(_ equation: String) -> [String]? {
        // 存储分词结果
        var tokens: [String] = []
        // 当前正在拼接的数字（可能是负数或小数）
        var currentNumber = ""
        // 记录上一个 token，用于判断当前 "-" 是否为一元负号
        var previousToken: String?
        
        // 逐字符扫描表达式
        for char in equation {
            // 将字符转成字符串，便于和运算符数组比较
            let str = String(char)
            
            // 数字或小数点：继续拼接当前数字
            if char.isNumber || char == "." {
                currentNumber.append(char)
                continue
            }
            
            // 遇到运算符
            if funcArray.contains(str) {
                // 一元负号条件：
                // 1) 当前字符是 "-"
                // 2) 前面没有 token，或前一个 token 也是运算符
                let isUnaryMinus = str == "-" && (previousToken == nil || funcArray.contains(previousToken!))
                if isUnaryMinus {
                    // 把 "-" 作为数字的一部分，例如 "-3"
                    currentNumber.append(char)
                    continue
                }
                
                // 遇到二元运算符前，先把已拼好的数字入栈
                if !currentNumber.isEmpty {
                    tokens.append(currentNumber)
                    // 更新上一个 token 为这个数字
                    previousToken = currentNumber
                    // 清空当前数字缓存，准备下一段
                    currentNumber = ""
                }
                
                // 当前运算符入栈
                tokens.append(str)
                // 更新上一个 token 为运算符
                previousToken = str
            } else {
                // 出现非法字符，直接返回 nil 表示分词失败
                return nil
            }
        }
        
        // 循环结束后，如果还有尾部数字，补入 tokens
        if !currentNumber.isEmpty {
            tokens.append(currentNumber)
        }
        
        // 返回分词结果
        return tokens
    }

    /// 根据运算符优先级执行计算
    private func evaluateTokens(_ tokens: [String]) -> Double? {
        // 数字栈：保存操作数
        var numbers: [Double] = []
        // 运算符栈：保存待执行的运算符
        var operators: [String] = []
        
        // 顺序读取每个 token
        for token in tokens {
            // token 是数字时直接压入数字栈
            if let number = Double(token) {
                numbers.append(number)
                continue
            }
            
            // token 不是数字时，必须是支持的运算符，否则失败
            guard funcArray.contains(token) else {
                return nil
            }
            
            // 当栈顶运算符优先级更高（或同级且应先算）时，先出栈计算
            while let lastOp = operators.last,
                  shouldApply(lastOp, before: token) {
                guard applyTopOperator(numbers: &numbers, operators: &operators) else {
                    return nil
                }
            }
            
            // 当前运算符入栈
            operators.append(token)
        }
        
        // 所有 token 扫描完成后，清空运算符栈并完成剩余计算
        while !operators.isEmpty {
            guard applyTopOperator(numbers: &numbers, operators: &operators) else {
                return nil
            }
        }
        
        // 正常情况下数字栈只剩 1 个值，即最终结果
        return numbers.count == 1 ? numbers[0] : nil
    }

    /// 判断栈顶运算符是否应在当前运算符入栈前先执行
    private func shouldApply(_ stackOp: String, before incomingOp: String) -> Bool {
        // 栈顶运算符优先级
        let stackPrecedence = precedence(of: stackOp)
        // 即将入栈运算符优先级
        let incomingPrecedence = precedence(of: incomingOp)
        
        // 栈顶优先级更高，先计算栈顶
        if stackPrecedence > incomingPrecedence {
            return true
        }
        
        // "^" 右结合：遇到同级 "^" 时不提前计算
        // 例如 2^3^2 需要按 2^(3^2) 处理
        if stackPrecedence == incomingPrecedence && incomingOp != "^" {
            return true
        }
        
        // 其余情况不提前计算
        return false
    }

    /// 返回运算符优先级（数值越大优先级越高）
    private func precedence(of op: String) -> Int {
        // 不同运算符返回对应优先级
        switch op {
        case "^":
            return 3
        case "*", "/", "%":
            return 2
        case "+", "-":
            return 1
        default:
            return 0
        }
    }

    /// 执行一次“出栈并计算”：
    /// 从 numbers 中取两个操作数，从 operators 取一个运算符并回填结果
    private func applyTopOperator(numbers: inout [Double], operators: inout [String]) -> Bool {
        // 取出一个运算符，且数字栈至少要有两个操作数
        guard let op = operators.popLast(), numbers.count >= 2 else {
            return false
        }
        
        // 先弹出右操作数，再弹出左操作数（顺序不能反）
        let right = numbers.removeLast()
        let left = numbers.removeLast()
        // 保存本次计算值
        let value: Double
        
        // 根据运算符执行对应运算
        switch op {
        case "+":
            value = left + right
        case "-":
            value = left - right
        case "*":
            value = left * right
        case "/":
            // 除数不能为 0
            guard right != 0 else { return false }
            value = left / right
        case "%":
            // 模运算右侧不能为 0
            guard right != 0 else { return false }
            value = left.truncatingRemainder(dividingBy: right)
        case "^":
            // 幂运算
            value = pow(left, right)
        default:
            // 未知运算符
            return false
        }
        
        // 把结果压回数字栈，参与后续计算
        numbers.append(value)
        return true
    }

}
