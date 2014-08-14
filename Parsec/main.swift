import Foundation


// doesn't compile
//typealias Parser<T> = String -> (T, String)

infix operator >>> { associativity left }
func >>><A,B>(lhs: String -> (A?, String), rhs: String -> (B?, String)) -> String -> (B?, String) {
    return { s in
        let (a, s2) = lhs(s)
        if a == nil {
            return (nil, s)
        }
        let (b, s3) = rhs(s2)
        if b == nil {
            return (nil, s)
        }
        return (b, s3)
    }
}

func run<T>(parser: String -> (T, String), input: String) -> (T, String) {
    return parser(input)
}

func matchChar(c: Character) -> String -> (Bool?, String) {
    return { s in
        let idx = s.startIndex
        if !s.isEmpty && s[idx] == c {
            return (true, s.substringFromIndex(advance(idx, 1)))
        } else {
            return (false, s)
        }
    }
}
    
func matchFoo() -> String -> (Bool?, String) {
    return (matchChar("f") >>> matchChar("o")) >>> matchChar("o")
}

var s = "cafoo!"
let parser = matchChar("c") >>> matchChar("a") >>> matchFoo()
var (ok, s2) = run(parser, s)
println("\(ok), remaining '\(s2)'")
