import lexerposition

type
    TokenType* = enum
        Plus, Star, Number, Minus, Slash, Semicolon
        Let, Equals, Identifier, Error, Eof

    Token* = object
        pos*: LexerPosition
        case kind*: TokenType
        of Error:
            message*: string
        else:
            lexeme*: string

proc makeToken*(tt: TokenType, str: string, pos: LexerPosition): Token =
    case tt:
    of Error:
        return Token(kind: Error, pos: pos, message: str)
    else:
        return Token(kind: tt, pos: pos, lexeme: str)

when isMainModule:
    echo "hi from token.nim"
