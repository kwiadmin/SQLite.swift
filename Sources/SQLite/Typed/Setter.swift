//
// SQLite.swift
// https://github.com/stephencelis/SQLite.swift
// Copyright © 2014-2015 Stephen Celis.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

precedencegroup ColumnAssignment {
    associativity: left
    assignment: true
    lowerThan: AssignmentPrecedence
}

infix operator <- : ColumnAssignment

public struct Setter {

    let column: SQLExpressible
    let value: SQLExpressible

    fileprivate init<V: Value>(column: SQLExpression<V>, value: SQLExpression<V>) {
        self.column = column
        self.value = value
    }

    fileprivate init<V: Value>(column: SQLExpression<V>, value: V) {
        self.column = column
        self.value = value
    }

    fileprivate init<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V>) {
        self.column = column
        self.value = value
    }

    fileprivate init<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V?>) {
        self.column = column
        self.value = value
    }

    fileprivate init<V: Value>(column: SQLExpression<V?>, value: V?) {
        self.column = column
        self.value = SQLExpression<V?>(value: value)
    }

    init(excluded column: SQLExpressible) {
        let excluded = SQLExpression<Void>("excluded")
        self.column = column
        value = ".".join([excluded, column.expression])
    }
}

extension Setter: SQLExpressible {

    public var expression: SQLExpression<Void> {
        "=".infix(column, value, wrap: false)
    }

}

public func <-<V: Value>(column: SQLExpression<V>, value: SQLExpression<V>) -> Setter {
    Setter(column: column, value: value)
}
public func <-<V: Value>(column: SQLExpression<V>, value: V) -> Setter {
    Setter(column: column, value: value)
}
public func <-<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V>) -> Setter {
    Setter(column: column, value: value)
}
public func <-<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V?>) -> Setter {
    Setter(column: column, value: value)
}
public func <-<V: Value>(column: SQLExpression<V?>, value: V?) -> Setter {
    Setter(column: column, value: value)
}

public func +=(column: SQLExpression<String>, value: SQLExpression<String>) -> Setter {
    column <- column + value
}
public func +=(column: SQLExpression<String>, value: String) -> Setter {
    column <- column + value
}
public func +=(column: SQLExpression<String?>, value: SQLExpression<String>) -> Setter {
    column <- column + value
}
public func +=(column: SQLExpression<String?>, value: SQLExpression<String?>) -> Setter {
    column <- column + value
}
public func +=(column: SQLExpression<String?>, value: String) -> Setter {
    column <- column + value
}

public func +=<V: Value>(column: SQLExpression<V>, value: SQLExpression<V>) -> Setter where V.Datatype: Number {
    column <- column + value
}
public func +=<V: Value>(column: SQLExpression<V>, value: V) -> Setter where V.Datatype: Number {
    column <- column + value
}
public func +=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V>) -> Setter where V.Datatype: Number {
    column <- column + value
}
public func +=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V?>) -> Setter where V.Datatype: Number {
    column <- column + value
}
public func +=<V: Value>(column: SQLExpression<V?>, value: V) -> Setter where V.Datatype: Number {
    column <- column + value
}

public func -=<V: Value>(column: SQLExpression<V>, value: SQLExpression<V>) -> Setter where V.Datatype: Number {
    column <- column - value
}
public func -=<V: Value>(column: SQLExpression<V>, value: V) -> Setter where V.Datatype: Number {
    column <- column - value
}
public func -=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V>) -> Setter where V.Datatype: Number {
    column <- column - value
}
public func -=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V?>) -> Setter where V.Datatype: Number {
    column <- column - value
}
public func -=<V: Value>(column: SQLExpression<V?>, value: V) -> Setter where V.Datatype: Number {
    column <- column - value
}

public func *=<V: Value>(column: SQLExpression<V>, value: SQLExpression<V>) -> Setter where V.Datatype: Number {
    column <- column * value
}
public func *=<V: Value>(column: SQLExpression<V>, value: V) -> Setter where V.Datatype: Number {
    column <- column * value
}
public func *=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V>) -> Setter where V.Datatype: Number {
    column <- column * value
}
public func *=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V?>) -> Setter where V.Datatype: Number {
    column <- column * value
}
public func *=<V: Value>(column: SQLExpression<V?>, value: V) -> Setter where V.Datatype: Number {
    column <- column * value
}

public func /=<V: Value>(column: SQLExpression<V>, value: SQLExpression<V>) -> Setter where V.Datatype: Number {
    column <- column / value
}
public func /=<V: Value>(column: SQLExpression<V>, value: V) -> Setter where V.Datatype: Number {
    column <- column / value
}
public func /=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V>) -> Setter where V.Datatype: Number {
    column <- column / value
}
public func /=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V?>) -> Setter where V.Datatype: Number {
    column <- column / value
}
public func /=<V: Value>(column: SQLExpression<V?>, value: V) -> Setter where V.Datatype: Number {
    column <- column / value
}

public func %=<V: Value>(column: SQLExpression<V>, value: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    column <- column % value
}
public func %=<V: Value>(column: SQLExpression<V>, value: V) -> Setter where V.Datatype == Int64 {
    column <- column % value
}
public func %=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    column <- column % value
}
public func %=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V?>) -> Setter where V.Datatype == Int64 {
    column <- column % value
}
public func %=<V: Value>(column: SQLExpression<V?>, value: V) -> Setter where V.Datatype == Int64 {
    column <- column % value
}

public func <<=<V: Value>(column: SQLExpression<V>, value: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    column <- column << value
}
public func <<=<V: Value>(column: SQLExpression<V>, value: V) -> Setter where V.Datatype == Int64 {
    column <- column << value
}
public func <<=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    column <- column << value
}
public func <<=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V?>) -> Setter where V.Datatype == Int64 {
    column <- column << value
}
public func <<=<V: Value>(column: SQLExpression<V?>, value: V) -> Setter where V.Datatype == Int64 {
    column <- column << value
}

public func >>=<V: Value>(column: SQLExpression<V>, value: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    column <- column >> value
}
public func >>=<V: Value>(column: SQLExpression<V>, value: V) -> Setter where V.Datatype == Int64 {
    column <- column >> value
}
public func >>=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    column <- column >> value
}
public func >>=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V?>) -> Setter where V.Datatype == Int64 {
    column <- column >> value
}
public func >>=<V: Value>(column: SQLExpression<V?>, value: V) -> Setter where V.Datatype == Int64 {
    column <- column >> value
}

public func &=<V: Value>(column: SQLExpression<V>, value: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    column <- column & value
}
public func &=<V: Value>(column: SQLExpression<V>, value: V) -> Setter where V.Datatype == Int64 {
    column <- column & value
}
public func &=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    column <- column & value
}
public func &=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V?>) -> Setter where V.Datatype == Int64 {
    column <- column & value
}
public func &=<V: Value>(column: SQLExpression<V?>, value: V) -> Setter where V.Datatype == Int64 {
    column <- column & value
}

public func |=<V: Value>(column: SQLExpression<V>, value: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    column <- column | value
}
public func |=<V: Value>(column: SQLExpression<V>, value: V) -> Setter where V.Datatype == Int64 {
    column <- column | value
}
public func |=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    column <- column | value
}
public func |=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V?>) -> Setter where V.Datatype == Int64 {
    column <- column | value
}
public func |=<V: Value>(column: SQLExpression<V?>, value: V) -> Setter where V.Datatype == Int64 {
    column <- column | value
}

public func ^=<V: Value>(column: SQLExpression<V>, value: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    column <- column ^ value
}
public func ^=<V: Value>(column: SQLExpression<V>, value: V) -> Setter where V.Datatype == Int64 {
    column <- column ^ value
}
public func ^=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    column <- column ^ value
}
public func ^=<V: Value>(column: SQLExpression<V?>, value: SQLExpression<V?>) -> Setter where V.Datatype == Int64 {
    column <- column ^ value
}
public func ^=<V: Value>(column: SQLExpression<V?>, value: V) -> Setter where V.Datatype == Int64 {
    column <- column ^ value
}

public postfix func ++<V: Value>(column: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    SQLExpression<Int>(column) += 1
}
public postfix func ++<V: Value>(column: SQLExpression<V?>) -> Setter where V.Datatype == Int64 {
    SQLExpression<Int>(column) += 1
}

public postfix func --<V: Value>(column: SQLExpression<V>) -> Setter where V.Datatype == Int64 {
    SQLExpression<Int>(column) -= 1
}
public postfix func --<V: Value>(column: SQLExpression<V?>) -> Setter where V.Datatype == Int64 {
    SQLExpression<Int>(column) -= 1
}
