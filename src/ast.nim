import token

type
    ASTNodeKind* = enum
        Number, BinaryOp, UnaryOp, Variable, Assignment, Empty

    ASTNode* = ref object
        case kind*: ASTNodeKind
        of Number:
            numValue*: int
        of BinaryOp:
            left*, right*: ASTNode
            binaryOp*: TokenType
        of UnaryOp:
            value*: ASTNode
            unaryOp*: TokenType
        of Variable:
            name*: string
        of Assignment:
            assName*: string
            assVal*: ASTNode
        of Empty:
            discard

proc newNumberNode*(value: int): ASTNode =
    return ASTNode(
        kind: Number,
        numValue: value
    )

proc newUnaryNode*(value: ASTNode, op: TokenType): ASTNode =
    return ASTNode(
        kind: UnaryOp,
        value: value,
        unaryOp: op
    )

proc newBinaryNode*(left, right: ASTNode, op: TokenType): ASTNode =
    return ASTNode(
        kind: BinaryOp,
        left: left,
        right: right,
        binaryOp: op
    )

proc newVariableNode*(name: string): ASTNode =
    return ASTNode(
        kind: Variable,
        name: name
    )

proc newAssignmentNode*(name: string, value: ASTNode): ASTNode =
    return ASTNode(
        kind: Assignment,
        assName: name,
        assVal: value
    )
