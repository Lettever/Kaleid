type
    LexerPosition* = object
        i*, line*, column*: int
        
proc default*(T: type LexerPosition): LexerPosition =
    return LexerPosition(i: 0, line: 1, column: 0)

proc nextLine*(pos: var LexerPosition) =
    pos.column = 0
    pos.line += 1
    
proc advance*(pos: var LexerPosition, cnt: int) =
    pos.i += cnt
    pos.column += cnt
