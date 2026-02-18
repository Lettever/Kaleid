import src/[lexer, token]

let program = readFile("src/example.kd")
echo program
let tokens = lex(program)
for t in tokens:
    echo t
