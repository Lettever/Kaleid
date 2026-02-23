import ast, token, parser
import std/[strformat, paths, os]

#codegen for qbe

type QBEGen* = object
    output: string
    tempCounter: int
    errors: seq[string]

proc new(T: type QBEGen): QBEGen =
    return QBEGen(output: "", tempCounter: 0, errors: newSeq[string]())
    
proc newTemp(qg: var QBEGen): string =
    result = &"%t{qg.tempCounter}"
    qg.tempCounter += 1
    
proc emit(qg: var QBEGen, line: string) =
    qg.output &= line & "\n"
    
proc error(qg: var QBEGen, message: string) = 
    qg.errors &= message
    
proc generateNumber(qg: var QBEGen, node: ASTNode): string = 
    assert node.kind == Number, "Invalid state on generateNumber, tried to call it when node is not a number"
    result = qg.newTemp()
    qg.emit(&"  {result} =w copy {node.numValue}")
    
proc generate*(qg: var QBEGen, node: ASTNode): string

proc generateUnaryOp(qg: var QBEGen, node: ASTNode): string =
    case node.unaryOp
    of Minus:
        let operand = qg.generate(node.value)
        result = qg.newTemp()
        qg.emit(&"  {result} =w neg {operand}")
    else:
        qg.error("Cannot generate code for empty node")
        result = "%0" 
    
proc generateBinaryOp(qg: var QBEGen, node: ASTNode): string =
    let leftTemp = qg.generate(node.left)
    let rightTemp = qg.generate(node.right)
    result = qg.newTemp()
    
    case node.binaryOp
    of Plus:
        qg.emit(&"  {result} =w add {leftTemp}, {rightTemp}")
    of Minus:
        qg.emit(&"  {result} =w sub {leftTemp}, {rightTemp}")
    of Star:
        qg.emit(&"  {result} =w mul {leftTemp}, {rightTemp}")
    of Slash:
        qg.emit(&"  {result} =w div {leftTemp}, {rightTemp}")
    else:
        qg.error(&"Unsupported operator: {node.binaryOp}")
        result = leftTemp

proc generate*(qg: var QBEGen, node: ASTNode): string =
    case node.kind
    of Number:
        result = qg.generateNumber(node)
    of UnaryOp:
        result = qg.generateUnaryOp(node)
    of BinaryOp:
        result = qg.generateBinaryOp(node)
    of Empty:
        qg.error("Cannot generate code for empty node")
        result = "%0"

proc generateProgram*(qg: var QBEGen, ast: ASTNode): string =
    qg.output = ""
    qg.emit("export function w $main() {")
    qg.emit("@start")
    
    let res = qg.generate(ast)
    qg.emit(&"  call $printf(l $fmt, ..., w {res})")
    qg.emit("  ret")

    qg.emit("}")
    qg.emit("")
    qg.emit("data $fmt = { b \"Result = %d\\n\\0\" }")
    
    return qg.output

when isMainModule:
    for _, file in walkDir("examples", true):
        let filepath = "examples/" & file
        let outpath = $Path("out-qbe/" & file).changeFileExt("qbe")
        echo filepath
        echo outpath
        var qg = QBEGen.new()
        let node = parse(filepath)
        let output = qg.generateProgram(node)
        writeFile(outpath, output)
        echo output
        echo ""
