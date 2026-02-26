import ast, token, parser
import std/[strformat, paths, os, tables]

#codegen for qbe

type QBEGen* = object
    output: string
    tempCounter: int
    variables: Table[string, string]
    errors: seq[string]

proc new(T: type QBEGen): QBEGen =
    return QBEGen(output: "", tempCounter: 0, errors: newSeq[string]())

proc newTemp(qg: var QBEGen): string =
    result = &"%t{qg.tempCounter}"
    qg.tempCounter += 1

proc newStackSlot(qg: var QBEGen): string =
    result = &"%s{qg.variables.len()}"
    qg.tempCounter += 1

proc emit(qg: var QBEGen, line: string) =
    qg.output &= line & "\n"

proc error(qg: var QBEGen, message: string) =
    qg.errors &= message

proc generate(qg: var QBEGen, node: ASTNode): string

proc generateAssignment(qg: var QBEGen, node: ASTNode): string =
    let value = qg.generate(node.assVal)
    if not qg.variables.hasKey(node.assName):
        let slot = qg.newStackSlot()
        qg.variables[node.assName] = slot
        qg.emit(&"  {slot} =l alloc8 8")

    let slot = qg.variables[node.assName]
    qg.emit(&"  storew {value}, {slot}")
    return value

proc generateVariable(qg: var QBEGen, node: ASTNode): string =
    if not qg.variables.hasKey(node.name):
        qg.error(&"Undefined variable: {node.name}")
        return qg.newTemp()

    let slot = qg.variables[node.name]
    result = qg.newTemp()
    qg.emit(&"  {result} =w loadsw {slot}")

proc generateNumber(qg: var QBEGen, node: ASTNode): string =
    assert node.kind == Number, "Invalid state on generateNumber, tried to call it when node is not a number"
    result = qg.newTemp()
    qg.emit(&"  {result} =w copy {node.numValue}")

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

proc generate(qg: var QBEGen, node: ASTNode): string =
    case node.kind
    of Number:
        result = qg.generateNumber(node)
    of UnaryOp:
        result = qg.generateUnaryOp(node)
    of BinaryOp:
        result = qg.generateBinaryOp(node)
    of Variable:
        result = qg.generateVariable(node)
    of Assignment:
        result = qg.generateAssignment(node)
    of Empty:
        qg.error("Cannot generate code for empty node")
        result = "%0"

proc generateProgram*(qg: var QBEGen, expressions: seq[ASTNode]): string =
    qg.output = ""
    qg.emit("export function w $main() {")
    qg.emit("@start")

    for ast in expressions:
        let res = qg.generate(ast)
        qg.emit(&"  call $printf(l $fmt, ..., w {res})")

    qg.emit("  ret 0")

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
