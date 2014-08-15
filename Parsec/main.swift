import Foundation

extension String {
    var tail: String {
    get {
        if self.isEmpty { return self }
        return self.substringFromIndex(advance(self.startIndex, 1))
    }
    }
}

//MARK:- the parser type
//
// typealias Parser<R> = String -> (R, String)
// doesn't compile in Xcode6-beta5
// so instead, declare a generic struct that's initialized with a closure

struct Parser<R> {
    let p: String -> (R, String)
}


//MARK:- combinators

// sequence operator where the former result is discarded, and the latter is kept
infix operator >>> { associativity left }
func >>><A,B>(lhs: Parser<A?>, rhs: Parser<B?>) -> Parser<B?> {
    return Parser { s in
        let (a, s2) = lhs.p(s)
        if a == nil {
            return (nil, s)
        }
        let (b, s3) = rhs.p(s2)
        if b == nil {
            return (nil, s)
        }
        return (b, s3)
    }
}

// sequence operator where the former result is kept, and the latter is discarded
infix operator >>>- { associativity left }
func >>>-<A,B>(lhs: Parser<A?>, rhs: Parser<B?>) -> Parser<A?> {
    return Parser { s in
        let (a, s2) = lhs.p(s)
        if a == nil {
            return (nil, s)
        }
        let (b, s3) = rhs.p(s2)
        if b == nil {
            return (nil, s)
        }
        return (a, s3)
    }
}


infix operator <|> { associativity left }
func <|><A>(lhs: Parser<A?>, rhs: Parser<A?>) -> Parser<A?> {
    return Parser { s in
        let (a, s2) = lhs.p(s)
        if a != nil {
            return (a, s2) // lhs-success
        }
        let (b, s3) = rhs.p(s)
        if b != nil {
            return (b, s3) // rhs-success
        }
        return (nil, s) // both sides failed
    }
}

func many1<A>(parser: Parser<A?>) -> Parser<[A]?> {
    return Parser { s in
        var (a:A?, s2) = (nil, s)
        var list = [A]()
        do {
            (a, s2) = parser.p(s2)
            if a != nil {
                list.append(a!)
            }
        } while a != nil && !s.isEmpty
        
        if list.count == 0 {
            return (nil, s)
        } else {
            return (list, s2)
        }
    }
}

// matches zero or more occurrences of `parser` up until `tillParser` matches once
func manyTill<A,B>(parser: Parser<A?>, tillParser: Parser<B?>) -> Parser<[A]?> {
    return Parser { s in
        let (ok, s2) = tillParser.p(s)
        if ok != nil {
            return ([A](), s2)
        }
        let (ok2, s3) = run(many1(parser) >>>- tillParser, s)
        if ok2 != nil {
            return (ok2, s3)
        }
        return (nil, s)
    }
}


func run<T>(parser: Parser<T>, input: String) -> (T, String) {
    return parser.p(input)
}

//MARK:- core parsers
func matchChar(c: Character) -> Parser<Bool?> {
    return Parser { s in
        if !s.isEmpty && s[s.startIndex] == c {
            return (true, s.tail)
        } else {
            return (nil, s)
        }
    }
}

func matchString(m: String) -> Parser<Bool?> {
    return Parser { s in
        if m.isEmpty {
            return (true, s)
        } else if s.isEmpty {
            return (nil, s)
        } else if m[m.startIndex] == s[s.startIndex] {
            return run(matchString(m.tail), (s.tail))
        } else {
            return (nil, s)
        }
    }
}

//MARK:- example of an "application" layer parser
func matchFoo() -> Parser<Bool?> {
    return matchChar("f") >>> matchChar("o") >>> matchChar("o")
}

//MARK:- demo code
var s = "kungfoo!"

func test<T>(parser: Parser<T?>, input: String) -> (Bool, String) {
    var (match, output) = run(parser, input)
    if match != nil {
        println("parse success: remaining='\(output)'")
        return (true, output)
    } else {
        println("parse failed: remaining='\(output)'")
        return (false, output)
    }
}

var parser = matchString("kung") >>> matchFoo()
test(parser, "kungfoo!")

let parser2 = matchChar(".") <|> matchChar("?") <|> matchChar("!")
test(parser2, "!")

let parser3 = matchChar("o") >>> (matchChar(".") <|> matchChar("?") <|> matchChar("!"))
test(parser3, "o.")

// there must be at least one z followed by a period
let parser4 = many1(matchChar("z")) >>> matchChar(".")
test(parser4, "zzz.")

// match any number of z's (including zero) followed by a period
let parser5 = manyTill(matchChar("z"), matchChar("."))
test(parser5, "zzz.")

// match any number of z's (including zero) followed by a period
let parser6 = manyTill(matchChar("z"), matchChar("."))
test(parser6, ".")



