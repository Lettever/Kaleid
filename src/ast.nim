import token

type
    ASTNodeKind* = enum
        Number, BinaryOp, UnaryOp, Empty

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
        of Empty:
            discard

proc newNumberNode*(value: int): ASTNode =
    return ASTNode(
        kind: Number,
        numValue: value
    )

proc newBinaryNode*(left, right: ASTNode, op: TokenType): ASTNode =
    return ASTNode(
        kind: BinaryOp,
        left: left,
        right: right,
        binaryOp: op
    )

proc newUnaryNode*(value: ASTNode, op: TokenType): ASTNode =
    return ASTNode(
        kind: UnaryOp,
        value: value,
        unaryOp: op
    )
