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

proc parseNumber(p: var Parser): ASTNode =
    if not p.check(Number):
        p.error("Expected Number")
        return nil
        
    let value = p.tokens[p.i].lexeme.parseInt()
    result = ASTNode(
        kind: Number,
        numValue: value
    )
    p.advance()

proc parseAdd(p: var Parser): ASTNode =
    var left = p.parseNumber()
    if left == nil:
        return nil
    
    while p.check(Plus):
        p.advance()
        let right = p.parseNumber()
        if right == nil:
            return nil
        
        left = ASTNode(
            kind: BinaryOp,
            left: left,
            right: right,
            op: Plus
        )
    
    return left
    
proc parse*(p: var Parser): ASTNode =
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
        result = nil

proc dumpAST*(node: ASTNode, indent: int = 0) =
    let prefix = repeat("  ", indent)
    
    case node.kind
    of Number:
        echo prefix & "Number: " & $node.numValue
    of BinaryOp:
        let opStr = case node.op
                    of Plus: "+"
                    else: "unknown"
        echo prefix & "BinaryOp (" & opStr & ")"
        dumpAST(node.left, indent + 1)
        dumpAST(node.right, indent + 1)
    of Empty:
        echo prefix & "Empty"

# Evaluate the AST and compute the result
proc evaluate*(node: ASTNode): int =
    case node.kind
    of Number:
        result = node.numValue
    
    of BinaryOp:
        let leftVal = evaluate(node.left)
        let rightVal = evaluate(node.right)
        case node.op
        of Plus: 
            result = leftVal + rightVal
        else:
            # Should not happen with valid AST
            result = 0
    
    of Empty:
        result = 0

when isMainModule:
    var l = Lexer.new(readFile("src/example.kd"))
    let tokens = l.collect()
    var p: Parser = Parser.new(tokens)
    let node = p.parse()
    dumpAST(node)    
    echo evaluate(node)
