import token

type
    ASTNodeKind* = enum
        Number, BinaryOp, Empty

    ASTNode* = ref object
        case kind*: ASTNodeKind
        of Number:
            numValue*: int
        of BinaryOp:
            left*, right*: ASTNode
            op*: TokenType
        of Empty:
            discard
