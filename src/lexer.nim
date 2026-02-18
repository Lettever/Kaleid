import token; export TokenType
import lexerposition; export advance
import parseutils, strutils

type
    Lexer = object
        src: string
        pos: LexerPosition

proc new(T: type Lexer, src: string): Lexer =
    return Lexer(
        src: src,
        pos: LexerPosition.default() 
    )

proc makeAndAdvance(l: var Lexer, kind: TokenType, lexeme: string): Token = 
    result = Token(
        kind: kind,
        lexeme: lexeme,
        pos: l.pos,
    )
    l.pos.advance(len(lexeme))

proc nextCh(l: var Lexer, ch: char) =
    l.pos.advance(1)
    if ch == '\n':
        l.pos.nextLine()

proc skipWhiteSpace(l: var Lexer) =
    let len = len(l.src)
    while l.pos.i < len and l.src[l.pos.i] in Whitespace:
        l.nextCh(l.src[l.pos.i])

proc readNumber(l: var Lexer): Token =
    var res: string
    if parseWhile(l.src, res, Digits, l.pos.i) == 0:
        return l.makeAndAdvance(Error, "")
    return l.makeAndAdvance(Number, res)

proc nextToken(l: var Lexer): Token =
    l.skipWhiteSpace()
    if l.pos.i >= len(l.src):
        return l.makeAndAdvance(Eof, "")
    let ch = l.src[l.pos.i]
    if ch in Digits:
        return l.readNumber()
    elif ch == '+':
        return l.makeAndAdvance(Plus, "+")

proc collect(l: var Lexer): seq[Token] =
    result = newSeq[Token]()
    var t = l.nextToken()
    while t.kind != Eof:
        result &= t
        t = l.nextToken()

proc lex*(s: string): seq[Token] = 
    var l = Lexer.new(s)
    return l.collect()