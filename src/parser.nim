import lexer, token, ast
import strutils, strformat

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

proc parseUnary(p: var Parser): ASTNode =
    if not p.check(Minus):
        p.error("Only a minus sign is supported for unary operations")
        return nil
    let op = p.peek()
    p.advance()
    let value = p.tokens[p.i].lexeme.parseInt()
    result = ASTNode(
        kind: UnaryOp,
        unaryOp: op,
        value: ASTNode(
            kind: Number,
            numValue: value
        )
    )
    p.advance()

proc parseNumber(p: var Parser): ASTNode =
    if p.check(Minus):
        let op = p.peek()
        p.advance()
        
        let value = p.parseNumber()
        if value == nil:
            return nil
        
        return newUnaryNode(value, op)
    
    if not p.check(Number):
        p.error("Expected number")
        return nil
        
    let value = p.tokens[p.i].lexeme.parseInt()
    result = newNumberNode(value)
    p.advance()

proc parseAdd(p: var Parser): ASTNode =
    var left = p.parseNumber()
    if left == nil:
        return nil
    
    while p.check(Plus) or p.check(Minus):
        let op = p.peek()
        p.advance()
        
        let right = p.parseNumber()
        if right == nil:
            return nil
        
        left = newBinaryNode(left, right, op)
    return left
    
proc parse(p: var Parser): ASTNode =
    if p.i >= len(p.tokens):
        p.error("Unexpected end of input")
        return nil
    
    result = p.parseAdd()
    
    # Check for unexpected tokens after the expression
    if result != nil and p.i < len(p.tokens) and p.peek() != Eof:
        let unexpectedToken = p.tokens[p.i]
        p.error(&"Unexpected token at line {unexpectedToken.pos.line}, column {unexpectedToken.pos.column}: '{unexpectedToken.lexeme}'")
        result = nil
    
    if len(p.errors) > 0:
        echo p.errors
        result = nil

proc parse*(program: string): ASTNode =
    var p = Parser.new(lex(program))
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
        else:
            # Should not happen with valid AST
            result = 0
    of UnaryOp:
        if node.unaryOp == Minus:
            result = -evaluate(node)
        else:
            echo &"{node.unaryOp} is not supported"
            result = evaluate(node)
    of Empty:
        result = 0

when isMainModule:
    let files = @["simple.kd", "minus.kd", "minus-plus.kd"]
    
    for file in files:
        let filepath = "examples/" & file
        echo filepath
        let node = parse(readFile(filepath))
        dumpAST(node)
        echo evaluate(node)
        echo ""
