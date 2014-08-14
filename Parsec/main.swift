import Foundation


func matchChar(c: Character, s: String) -> (Bool, String) {
    let idx = s.startIndex
    if !s.isEmpty && s[idx] == c {
        return (true, s.substringFromIndex(advance(idx, 1)))
    } else {
        return (false, s)
    }
}

func matchFoo(input: String) -> (Bool, String) {
    var ok = false
    var s = input
    (ok, s) = matchChar("f", s)
    if !ok { return (false, s) }
    (ok, s) = matchChar("o", s)
    if !ok { return (false, s) }
    (ok, s) = matchChar("o", s)
    if !ok { return (false, s) }
    return (ok, s)
}

var s = "cfoo"
var ok = false

(ok, s) = matchChar("c", s)
println("\(ok), remaining '\(s)'")

(ok, s) = matchFoo(s)
println("\(ok), remaining '\(s)'")

(ok, s) = matchChar("!", s)
println("\(ok), remaining '\(s)'")

