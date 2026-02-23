import lexer, token, ast
import std/[strutils, strformat]

type
    Parser = object 
        tokens: seq[Token]
        i: int
        errors: seq[string]
        
proc new(T: type Parser, tokens: seq[Token]): Parser = 
    result = Parser(
        tokens: tokens,
        i: 0,
        errors: newSeq[string]()
    )

proc error(p: var Parser, message: string) =
    p.errors &= message

proc advance(p: var Parser) =
    p.i += 1

proc peek(p: Parser): TokenType =
    if p.i < len(p.tokens):
        return p.tokens[p.i].kind
    return Eof

proc check(p: Parser, tt: TokenType): bool =
    return p.peek() == tt

proc expect(p: var Parser, tt: TokenType, message: string): bool =
    if p.check(tt):
        p.advance()
        return true
    else:
        p.error(message)
        return false

proc parseFactor(p: var Parser): ASTNode =
    if p.check(Minus):
        let op = p.peek()
        p.advance()
        
        let operand = p.parseFactor()
        if operand == nil:
            return nil
        
        return newUnaryNode(operand, op)
    
    if not p.check(Number):
        p.error("Expected number")
        return nil
        
    let value = p.tokens[p.i].lexeme.parseInt()
    result = newNumberNode(value)
    p.advance()

proc parseTerm(p: var Parser): ASTNode =
    var left = p.parseFactor()
    if left == nil:
        return nil
    
    while p.check(Star) or p.check(Slash):
        let op = p.peek()
        p.advance()
        
        let right = p.parseFactor()
        if right == nil:
            return nil
        
        left = newBinaryNode(left, right, op)
    
    return left

proc parseExpression(p: var Parser): ASTNode =
    var left = p.parseTerm()
    if left == nil:
        return nil
    
    while p.check(Plus) or p.check(Minus):
        let op = p.peek()
        p.advance()
        
        let right = p.parseTerm()
        if right == nil:
            return nil
        
        left = newBinaryNode(left, right, op)
    

    if not p.expect(Semicolon, "Semicolon expected"):
        echo "missing semicolon"
        return nil

    return left

proc parse*(p: var Parser): seq[ASTNode] =
    result = newSeq[ASTNode]()

    while p.i < len(p.tokens) and p.peek() != EOF:
        let exp = p.parseExpression()
        if exp == nil:
            p.error("Failed to parse expression in parse(p) function")
            return @[]
        result.add(exp)

proc parse*(file: string): seq[ASTNode] =
    var p = Parser.new(lex(file))
    return parse(p)

proc dumpAST*(node: ASTNode, indent: int = 0) =
    let prefix = repeat("  ", indent)
    if node == nil:
        echo prefix & "nil"
        return
    
    case node.kind
    of Number:
        echo prefix & "Number: " & $node.numValue
    of UnaryOp:
        let opStr = case node.unaryOp
                    of Minus: "-"
                    else: "unknown"
        echo prefix & "UnaryOp (" & opStr & ")"
        dumpAST(node.value, indent + 1)
    of BinaryOp:
        let opStr = case node.binaryOp
                    of Plus: "+"
                    of Minus: "-"
                    of Star: "*"
                    of Slash: "/"
                    else: "unknown"
        echo prefix & "BinaryOp (" & opStr & ")"
        dumpAST(node.left, indent + 1)
        dumpAST(node.right, indent + 1)
    of Empty:
        echo prefix & "Empty"

proc evaluate(node: ASTNode): int =
    case node.kind
    of Number:
        result = node.numValue
    of BinaryOp:
        let leftVal = evaluate(node.left)
        let rightVal = evaluate(node.right)
        case node.binaryOp
        of Plus:
            result = leftVal + rightVal
        of Minus:
            result = leftVal - rightVal
        of Star:
            result = leftVal * rightVal
        of Slash:
            assert rightVal != 0, "Division by zero in evaluate"
            result = leftVal div rightVal
        else:
            # Should not happen with valid AST
            result = 0
    of UnaryOp:
        case node.unaryOp:
        of Minus:
            result = -evaluate(node.value)
        else:
            echo &"{node.unaryOp} is not supported"
            result = evaluate(node)
    of Empty:
        result = 0

when isMainModule:
    import std/os
    for _, filepath in walkDir("examples"):
        #if filepath == "examples\\negative.kd":  continue
        #if filepath == "examples\\negative2.kd": continue
        #if filepath == "examples\\negative3.kd": continue
        echo filepath
        let node = parse(filepath)
        #dumpAST(node)
        #echo evaluate(node)
        
        for n in node:
            dumpAST(n)
        
        echo ""
