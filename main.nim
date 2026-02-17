import src/[lexer, parser, token]

let tokens = block:
    var lexer = Lexer.new(readFile("src/example.kd"))
    lexer.collect()
    
echo tokens
