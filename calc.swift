import UIKit
import Darwin
import Foundation

class ViewController: UIViewController
{

    @IBOutlet weak var display: UILabel!
    
    var firstClick:Bool = true
 
    //adds numbers to the screen based off what button the user clicks
    @IBAction func AddToDisplay(sender: UIButton)
    {
        let input = sender.currentTitle!
        if(!firstClick)
        {
            display.text = display.text! + input
        }
        else
        {
            display.text = input
            firstClick = false;
        }
    }
    
    @IBAction func Clear()
    {
        display.text = "0"
        firstClick = true
    }
    
    func isDigit(char:Character)->Bool
    {
        if char >= "0" && char <= "9"
        {
            return true
        }
        return false
    }
    func isDigit(char:String)->Bool
    {
        if char >= "0" && char <= "9"
        {
            return true
        }
        return false
    }
    func isOperator(char:String)->Bool
    {
        if char == "+" || char == "-" || char == "*" || char == "/"
        {
            return true
        }
        return false
    }
    //returns true if char has precedence thats greater than or equal to char2
    func checkPrecedence(char:String, char2:String)->Bool
    {
        if char == "+" || char == "-"
        {
            if char2 == "+" || char2 == "-"
            {
                return true
            }
        }
        else if char == "*" || char == "/"
        {
            if char2 == "*" || char2 == "/" || char2 == "+" || char2 == "-"
            {
                return true
            }
        }
        return false
    }
    
    func doMath (operation: String, first:String, second:String)->Double
    {
        var tree = BSTree()
        tree.insert(operation)
        tree.insert(first)
        tree.insert(second)
        return tree.evaluateBSTree(tree.getRoot())
    }

    var negNums = Array<Boolean>() //array determining if negative values are present
    
    func getAsStack(str:String)->Array<String>
    {
        negNums.removeAll(keepCapacity: true)
        var numStack = Array<Double>()
        var results = Array<String>()
        var numDecimals = 0
        var tokenInt = ""
        var tokenOperand:Character = " " //starts off at magic number g
        var firstNum = true

        var alreadyNegativeDecimal = false
        for char in display.text!
        {
            if isDigit(char) || char == "."
            {
                if tokenOperand != " "
                {
                    results.append(String(tokenOperand))
                    negNums.append(0)
                }
                tokenOperand = " "
                tokenInt.append(char)
                firstNum = false
            }
            else if char == "*" || char == "/" || char == "+" || char == "-"
            {
                if ((tokenOperand != " " || firstNum) && char == "-")
                {
                    if !firstNum
                    {
                        results.append(String(tokenOperand))
                        negNums.append(0) //for the previous token
                    }
                    negNums.append(1) //for the negative
                    tokenOperand = " "
                    alreadyNegativeDecimal = true
                    continue
                }
                else if(tokenInt[tokenInt.startIndex] == "." && !alreadyNegativeDecimal)
                {
                    tokenInt = String(tokenInt)
                    tokenInt = "0" + tokenInt
                    results.append(tokenInt)
                    negNums.append(0)
                }
                else if tokenInt[tokenInt.startIndex] == "."
                {
                    tokenInt = String(tokenInt)
                    tokenInt = "0" + tokenInt
                    results.append(tokenInt)
                    alreadyNegativeDecimal = false
                }
                else
                {
                    results.append(String(tokenInt))
                    if alreadyNegativeDecimal
                    {
                       // negNums.append(1)
                    }
                    else
                    {
                        negNums.append(0)
                    }
                }
                tokenInt = ""
                tokenOperand = char
                firstNum = false
            }
        }
        if tokenInt.utf16Count > 0
        {
            print("the tokenInt is")
            println(tokenInt)
            if(tokenInt[tokenInt.startIndex] == ".")
            {
                tokenInt = String(tokenInt)
                tokenInt = "0" + tokenInt
                results.append(tokenInt)
                if(negNums.count == 0 || negNums.last == 0)
                {
                   negNums.append(0)
                }
                
            }
            else
            {
                results.append(String(tokenInt))
                if (tokenOperand != " ")
                {
                    negNums.append(0)
                }
            }

        }
        if tokenOperand != " "
        {
            results.append(String(tokenOperand))
        }
        println("RESULTS ARE")
        for i in results
        {
            println(i)
        }
        println("negatives are")
        for i in negNums
        {
            println(i)
        }
        return results
    }
    
    var negNum2 = Array<Boolean>()

    func toPostFix(str:String)->Array<String>
    {
        negNum2.removeAll(keepCapacity: true)
        var negNumStack = Array<Boolean>()
        var OperatorStack = Array<String>()
        var postfix = Array<String>()
        var numStack = Array<Double>()
        var results = getAsStack(str)
        let size = results.count
        print("the size is ")
        println(size)
        for (var i = 0; i < size; i++)
        {
            let argument:String = results.removeAtIndex(0)
            if(isDigit(argument))
            {
                postfix.append(argument)
                negNum2.append(negNums.removeAtIndex(0))
            }
            else if (isOperator(argument))
            {
                if(OperatorStack.count == 0)
                {
                    OperatorStack.append(argument)
                    negNumStack.append(negNums.removeAtIndex(0))
                }
            
                else
                {
                    for j in OperatorStack.reverse()
                    {
                    
                        //if the precedence of j is greater than or equal to the precedences of i
                        if checkPrecedence(j, char2: argument)
                        {
                            if OperatorStack.count != 0
                            {
                                postfix.append(j)
                                negNum2.append(negNumStack.removeLast())
                                OperatorStack.removeLast()
                            }
                            else
                            {
                                //Error if this actually gets called
                                break
                            }
                        }
                    }
                OperatorStack.append(argument)
                negNumStack.append(negNums.removeAtIndex(0))
                }

            }
        }
        for i in OperatorStack.reverse()
        {
            postfix.append(i)
            negNum2.append(negNumStack.removeAtIndex(countElements(negNumStack) - 1))
        }
        println("Neg nums are")
        for i in negNum2{
            println(i)
        }
        println("numbers are ")
        for i in postfix{
            println(i)
        }
       return postfix
    }
    
    func evaluate (postfix:Array<String>)
    {
        var negNum3 = Array<Boolean>()
        var numStack = Array<String>()
        var OperatorStack = Array<String>()
        for i in postfix{
            if(isDigit(i))
            {
                numStack.append(i)
                negNum3.append(negNum2.removeAtIndex(0))
            }
            else
            {
                let second = numStack.last
                numStack.removeLast()
                let first = numStack.last
                numStack.removeLast()
                let signsecond = negNum3.last
                negNum3.removeLast()
                let signfirst = negNum3.last
                negNum3.removeLast()
                var value:Double
                switch (i)
                {
                    case "+":
                            //case -first + -second
                            if(signsecond == 1 && signsecond == 1)
                            {
                                negNum3.append(1)
                                value = doMath(i, first: first!, second: second!)
                            }
                            //case -first + second
                            else if (signsecond == 1 && signsecond == 0)
                            {
                                value = doMath("-", first: second!, second: first!)
                                //in the case of negative result
                                if (value < 0)
                                {
                                    negNum3.append(1)
                                }
                                else
                                {
                                    negNum3.append(0)
                                }
                            }
                            //case first+-second
                            else if (signsecond == 0 && signsecond == 1)
                            {
                                value = doMath(i, first: first!, second: second!)
                                if (value < 0)
                                {
                                    negNum3.append(1)
                                }
                                else
                                {
                                    negNum3.append(0)
                                }
                            }
                            else{
                                value = doMath(i, first: first!, second: second!)
                                negNum3.append(0)
                            }
                            break
                    case "-":
                        //case -first - -second => second - first
                        if(signsecond == 1 && signsecond == 1)
                        {
                            negNum3.append(1)
                            value = doMath(i, first: second!, second: first!)
                        }
                            //case -first - second
                        else if (signsecond == 1 && signsecond == 0)
                        {
                            value = doMath("+", first: first!, second: second!)
                            //in the case of negative result
                            negNum3.append(1)
                        }
                            //case first - -second
                        else if (signsecond == 0 && signsecond == 1)
                        {
                            value = doMath("+", first: first!, second: second!)
                            negNum3.append(0)
                        }
                        else{
                            value = doMath(i, first: first!, second: second!)
                            negNum3.append(0)
                        }
                        break
                    case "*":
                        //case -first * -second
                        if(signsecond == 1 && signsecond == 1)
                        {
                            negNum3.append(0)
                            value = doMath(i, first: second!, second: first!)
                        }
                        //case -first - second
                        else if (signsecond == 1 || signsecond == 1)
                        {
                            negNum3.append(1)
                            value = doMath(i, first: second!, second: first!)
                        }
                            //case first - -second
                        else{
                            value = doMath(i, first: first!, second: second!)
                            negNum3.append(0)
                        }
                        break
                    case "/":
                        //case -first * -second
                        if(signsecond == 1 && signsecond == 1)
                        {
                            negNum3.append(0)
                            value = doMath(i, first: second!, second: first!)
                        }
                            //case -first - second
                        else if (signsecond == 1 || signsecond == 1)
                        {
                            negNum3.append(1)
                            value = doMath(i, first: second!, second: first!)
                        }
                            //case first - -second
                        else{
                            value = doMath(i, first: first!, second: second!)
                            negNum3.append(0)
                        }
                    break
                    default:
                        value = 0
                            break
                }
                let myString = NSString(format: "%.7f", value)
                numStack.append(myString)
            }
        }
        if(negNum3.first! == 1)
        {
            display.text! = "-"
        }
        else{
            display.text! = ""
        }
        display.text! += numStack.first!
        firstClick = true
    }
    
    @IBAction func Root() {
        var numbers = 0
        var operands = 0
        var decimals = 0
        Compute()
        println(display.text!)
        for char in display.text!{
           if (char == "+" || char == "-" || char == "/" || char == "*")
            {
                operands++
            }
            else if(char == ".")
            {
                decimals++
            }
        }
        if (operands > 0 || decimals > 1)
        {
            display.text! = "ERROR"
            firstClick = true
            return
        }
        display.text = "\(sqrt(NSNumberFormatter().numberFromString(display.text!)!.doubleValue))"
    }
    
    @IBAction func Compute()
    {
        evaluate(toPostFix(display.text!))
    }
}
