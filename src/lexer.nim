import token; export TokenType
import lexerposition; export advance
import std/[parseutils, strutils, strformat]

type Lexer = object
    file: string
    src: string
    pos: LexerPosition

proc makeErrorMessage(l: Lexer, message: string): string =
    return &"{l.file}:{l.pos.line}:{l.pos.column} - {message}"

proc new(T: type Lexer, file: string): Lexer =
    return Lexer(
        file: file,
        src: readFile(file),
        pos: LexerPosition.default() 
    )

proc makeAndAdvance(l: var Lexer, kind: TokenType, str: string): Token = 
    result = makeToken(kind, str, l.pos)
    case kind:
    of Error:
        l.pos.advance(1)
    else:
        l.pos.advance(len(str))

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
        return l.makeAndAdvance(Error, makeErrorMessage(l, "readNumber"))
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
    elif ch == '-':
        return l.makeAndAdvance(Minus, "-")
    elif ch == '*':
        return l.makeAndAdvance(Star, "*")
    elif ch == '/':
        return l.makeAndAdvance(Slash, "/")
    return l.makeAndAdvance(Error, makeErrorMessage(l, &"{ch}"))

proc collect(l: var Lexer): seq[Token] =
    result = newSeq[Token]()
    var t = l.nextToken()
    while t.kind != Eof:
        result &= t
        t = l.nextToken()

proc lex*(s: string): seq[Token] =
    var l = Lexer.new(s)
    return l.collect()

when isMainModule:
    import std/os
    for _, filepath in walkDir("examples"):
        echo filepath
        for t in lex(filepath):
            echo t
        echo ""
