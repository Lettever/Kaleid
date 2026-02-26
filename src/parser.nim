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

proc advance(p: var Parser) =
    p.i += 1

proc current(p: Parser): Token =
    return p.tokens[p.i]

proc error(p: var Parser, message: string) =
    if p.i < len(p.tokens):
        let token = p.current()
        p.errors &= &"Error at line {token.pos.line}, column {token.pos.column}: {message}"
    else:
        p.errors &= &"Error: {message}"

proc peek(p: Parser): TokenType =
    if p.i < len(p.tokens):
        return p.current().kind
    return Eof

proc check(p: Parser, tt: TokenType): bool =
    return p.peek() == tt

proc expect(p: var Parser, tt: TokenType, message: string): bool =
    if p.check(tt):
        p.advance()
        return true
    else:
        let got = if p.i < len(p.tokens): $p.peek() else: "EOF"
        p.error(&"{message}. Got {got} instead of {tt}")
        return false

proc parseExpression(p: var Parser): ASTNode

proc parseVariableDeclaration(p: var Parser): ASTNode =
    if not p.expect(Let, "Expected 'let'"):
        return nil

    if not p.check(Identifier):
        p.error("Expected variable name after 'let'")
        return nil

    let name = p.current().lexeme
    p.advance()

    if p.check(Equals):
        p.advance()

        let value = p.parseExpression()
        if value == nil:
            return nil

        return newAssignmentNode(name, value)
    else:
        let zero = newNumberNode(0)
        return newAssignmentNode(name, zero)

proc parseAssignment(p: var Parser): ASTNode =
    if not p.check(Identifier):
        return nil

    let name = p.current().lexeme
    p.advance()

    if not p.check(Equals):
        return newVariableNode(name)

    p.advance()
    let value = p.parseExpression()
    if value == nil:
        return nil
    return newAssignmentNode(name, value)

proc parseFactor(p: var Parser): ASTNode =
    if p.check(Minus):
        let op = p.peek()
        p.advance()

        let operand = p.parseFactor()
        if operand == nil:
            return nil

        return newUnaryNode(operand, op)

    if p.check(Number):
        let value = p.current().lexeme.parseInt()
        p.advance()
        return newNumberNode(value)

    if p.check(Let):
        return p.parseVariableDeclaration()

    if p.check(Identifier):
        return p.parseAssignment()

    p.error("Unexpected token")
    return nil

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

    return left

proc parseStatement(p: var Parser): ASTNode =
    let expr = p.parseExpression()
    if expr == nil:
        return nil
    if not p.expect(Semicolon, "Expected ';' after expression"):
        return nil

    return expr

proc parse*(p: var Parser): seq[ASTNode] =
    result = newSeq[ASTNode]()

    while p.i < len(p.tokens) and p.peek() != EOF:
        let stmt = p.parseStatement()
        if stmt == nil:
            p.error("Failed to parse expression in parse(p) function")
            break
        result.add(stmt)
    for err in p.errors:
        echo err

proc parse*(file: string): seq[ASTNode] =
    var p = Parser.new(lex(file))
    return parse(p)

proc dumpAST*(node: ASTNode, indent: int = 0) =
    let prefix = repeat("  ", indent)
    if node == nil:
        echo prefix & "nil"
        return

    echo prefix & "Node kind: " & $node.kind

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
    of Variable:
        echo prefix & "Variable " & node.name
    of Assignment:
        echo prefix & "Assignment: " & node.assName
        dumpAST(node.assVal, indent + 1)
    of Empty:
        echo prefix & "Empty"


#[
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
]#
proc dumpASTDebug*(node: ASTNode, indent: int = 0) =
    let prefix = repeat("  ", indent)

    if node == nil:
        echo prefix & "ERROR: nil node"
        return
    else:
        echo prefix & "Node is not nil"

    echo prefix & "Node kind: " & $node.kind

    case node.kind
    of Number:
        echo prefix & "  Number value: " & $node.numValue

    of BinaryOp:
        echo prefix & "  Operator: " & $node.binaryOp
        echo prefix & "  Left:"
        dumpAST(node.left, indent + 2)
        echo prefix & "  Right:"
        dumpAST(node.right, indent + 2)

    of UnaryOp:
        echo prefix & "  Operator: " & $node.unaryOp
        echo prefix & "  Operand:"
        dumpAST(node.right, indent + 2)

    of Variable:
        echo prefix & "  Variable name: '" & node.name & "'"

    of Assignment:
        echo prefix & "  Variable name: '" & node.assName & "'"
        echo prefix & "  Value:"
        dumpAST(node.assVal, indent + 2)

    of Empty:
        echo prefix & "  (empty)"

when isMainModule:
    import std/os
    for _, filepath in walkDir("examples"):
        if filepath != "examples/variable.kd":
            continue
        echo filepath
        let node = parse(filepath)
        echo &"Got {len(node)} nodes"

        for n in node:
            dumpAST(n)

        echo ""
