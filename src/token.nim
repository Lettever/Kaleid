import lexerposition

type
    TokenType* = enum
        Plus, Number, Minus
        Error, Eof

    Token* = object
        kind*: TokenType
        lexeme*: string
        pos*: LexerPosition
