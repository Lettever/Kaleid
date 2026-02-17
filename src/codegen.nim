import ast, token
import std/strformat

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
    
proc error(qg: var QBEGen: message: string) = 
    qg.errors &= message
    
proc generateNumber(qg: var QBEGen, node: ASTNode): string = 
    result = qg.newTemp()
    qg.emit(&"  {result} =w copy {node.numValue}")
    
proc generateBinOp(qg: var QBEGen, node: ASTNode): string =
    let leftTemp = qg.generate(node.left)
    let rightTemp = qg.generate(node.right)
    
    result = qg.newTemp()
    
    case node.op
    of Plus:
        qg.emit(&"  {result} =w add {leftTemp}, {rightTemp}")
    else:
        qg.error(&"Unsupported operator: {node.op}")
        result = leftTemp
    
    return result

proc generate*(qg: var QBEGen, node: ASTNode): string =
    case node.kind
    of Number:
        result = qg.generateNumber(node)
    of BinaryOp:
        result = qg.generateBinaryOp(node)
    of Empty:
        qg.error("Cannot generate code for empty node")
        result = "%0"

proc generateProgram*(qg: QBEGen, ast: ASTNode): string =
    qb.output = ""
    qg.emit("export function w $main() {")
    qg.emit("@start")
    
    let result = qg.generate(ast)
    
    qg.emit(&"  ret {result}")
    qg.emit("}")
    
    return qg.output

