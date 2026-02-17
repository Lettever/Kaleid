import lexerposition

type
    TokenType* = enum
        Plus, Number, Error, Eof

    Token* = object
        kind*: TokenType
        lexeme*: string
        pos*: LexerPosition
