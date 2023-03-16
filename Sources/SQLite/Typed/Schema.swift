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

extension SchemaType {

    // MARK: - DROP TABLE / VIEW / VIRTUAL TABLE

    public func drop(ifExists: Bool = false) -> String {
        drop("TABLE", tableName(), ifExists)
    }

}

extension Table {

    // MARK: - CREATE TABLE

    public func create(temporary: Bool = false, ifNotExists: Bool = false, withoutRowid: Bool = false,
                       block: (SQLTableBuilder) -> Void) -> String {
        let builder = SQLTableBuilder()

        block(builder)

        let clauses: [SQLExpressible?] = [
            create(Table.identifier, tableName(), temporary ? .temporary : nil, ifNotExists),
            "".wrap(builder.definitions) as SQLExpression<Void>,
            withoutRowid ? SQLExpression<Void>(literal: "WITHOUT ROWID") : nil
        ]

        return " ".join(clauses.compactMap { $0 }).asSQL()
    }

    public func create(_ query: QueryType, temporary: Bool = false, ifNotExists: Bool = false) -> String {
        let clauses: [SQLExpressible?] = [
            create(Table.identifier, tableName(), temporary ? .temporary : nil, ifNotExists),
            SQLExpression<Void>(literal: "AS"),
            query
        ]

        return " ".join(clauses.compactMap { $0 }).asSQL()
    }

    // MARK: - ALTER TABLE … ADD COLUMN

    public func addColumn<V: Value>(_ name: SQLExpression<V>, check: SQLExpression<Bool>? = nil, defaultValue: V) -> String {
        addColumn(definition(name, V.declaredDatatype, nil, false, false, check, defaultValue, nil, nil))
    }

    public func addColumn<V: Value>(_ name: SQLExpression<V>, check: SQLExpression<Bool?>, defaultValue: V) -> String {
        addColumn(definition(name, V.declaredDatatype, nil, false, false, check, defaultValue, nil, nil))
    }

    public func addColumn<V: Value>(_ name: SQLExpression<V?>, check: SQLExpression<Bool>? = nil, defaultValue: V? = nil) -> String {
        addColumn(definition(name, V.declaredDatatype, nil, true, false, check, defaultValue, nil, nil))
    }

    public func addColumn<V: Value>(_ name: SQLExpression<V?>, check: SQLExpression<Bool?>, defaultValue: V? = nil) -> String {
        addColumn(definition(name, V.declaredDatatype, nil, true, false, check, defaultValue, nil, nil))
    }

    public func addColumn<V: Value>(_ name: SQLExpression<V>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                    references table: QueryType, _ other: SQLExpression<V>) -> String where V.Datatype == Int64 {
        addColumn(definition(name, V.declaredDatatype, nil, false, unique, check, nil, (table, other), nil))
    }

    public func addColumn<V: Value>(_ name: SQLExpression<V>, unique: Bool = false, check: SQLExpression<Bool?>,
                                    references table: QueryType, _ other: SQLExpression<V>) -> String where V.Datatype == Int64 {
        addColumn(definition(name, V.declaredDatatype, nil, false, unique, check, nil, (table, other), nil))
    }

    public func addColumn<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                    references table: QueryType, _ other: SQLExpression<V>) -> String where V.Datatype == Int64 {
        addColumn(definition(name, V.declaredDatatype, nil, true, unique, check, nil, (table, other), nil))
    }

    public func addColumn<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool?>,
                                    references table: QueryType, _ other: SQLExpression<V>) -> String where V.Datatype == Int64 {
        addColumn(definition(name, V.declaredDatatype, nil, true, unique, check, nil, (table, other), nil))
    }

    public func addColumn<V: Value>(_ name: SQLExpression<V>, check: SQLExpression<Bool>? = nil, defaultValue: V,
                                    collate: Collation) -> String where V.Datatype == String {
        addColumn(definition(name, V.declaredDatatype, nil, false, false, check, defaultValue, nil, collate))
    }

    public func addColumn<V: Value>(_ name: SQLExpression<V>, check: SQLExpression<Bool?>, defaultValue: V,
                                    collate: Collation) -> String where V.Datatype == String {
        addColumn(definition(name, V.declaredDatatype, nil, false, false, check, defaultValue, nil, collate))
    }

    public func addColumn<V: Value>(_ name: SQLExpression<V?>, check: SQLExpression<Bool>? = nil, defaultValue: V? = nil,
                                    collate: Collation) -> String where V.Datatype == String {
        addColumn(definition(name, V.declaredDatatype, nil, true, false, check, defaultValue, nil, collate))
    }

    public func addColumn<V: Value>(_ name: SQLExpression<V?>, check: SQLExpression<Bool?>, defaultValue: V? = nil,
                                    collate: Collation) -> String where V.Datatype == String {
        addColumn(definition(name, V.declaredDatatype, nil, true, false, check, defaultValue, nil, collate))
    }

    fileprivate func addColumn(_ expression: SQLExpressible) -> String {
        " ".join([
            SQLExpression<Void>(literal: "ALTER TABLE"),
            tableName(),
            SQLExpression<Void>(literal: "ADD COLUMN"),
            expression
        ]).asSQL()
    }

    // MARK: - ALTER TABLE … RENAME TO

    public func rename(_ to: Table) -> String {
        rename(to: to)
    }

    // MARK: - CREATE INDEX

    public func createIndex(_ columns: SQLExpressible..., unique: Bool = false, ifNotExists: Bool = false) -> String {
        let clauses: [SQLExpressible?] = [
            create("INDEX", indexName(columns), unique ? .unique : nil, ifNotExists),
            SQLExpression<Void>(literal: "ON"),
            tableName(qualified: false),
            "".wrap(columns) as SQLExpression<Void>
        ]

        return " ".join(clauses.compactMap { $0 }).asSQL()
    }

    // MARK: - DROP INDEX

    public func dropIndex(_ columns: SQLExpressible..., ifExists: Bool = false) -> String {
        drop("INDEX", indexName(columns), ifExists)
    }

    fileprivate func indexName(_ columns: [SQLExpressible]) -> SQLExpressible {
        let string = (["index", clauses.from.name, "on"] + columns.map { $0.expression.template }).joined(separator: " ").lowercased()

        let index = string.reduce("") { underscored, character in
            guard character != "\"" else {
                return underscored
            }
            guard "a"..."z" ~= character || "0"..."9" ~= character else {
                return underscored + "_"
            }
            return underscored + String(character)
        }

        return database(namespace: index)
    }

}

extension View {

    // MARK: - CREATE VIEW

    public func create(_ query: QueryType, temporary: Bool = false, ifNotExists: Bool = false) -> String {
        let clauses: [SQLExpressible?] = [
            create(View.identifier, tableName(), temporary ? .temporary : nil, ifNotExists),
            SQLExpression<Void>(literal: "AS"),
            query
        ]

        return " ".join(clauses.compactMap { $0 }).asSQL()
    }

    // MARK: - DROP VIEW

    public func drop(ifExists: Bool = false) -> String {
        drop("VIEW", tableName(), ifExists)
    }

}

extension VirtualTable {

    // MARK: - CREATE VIRTUAL TABLE

    public func create(_ using: Module, ifNotExists: Bool = false) -> String {
        let clauses: [SQLExpressible?] = [
            create(VirtualTable.identifier, tableName(), nil, ifNotExists),
            SQLExpression<Void>(literal: "USING"),
            using
        ]

        return " ".join(clauses.compactMap { $0 }).asSQL()
    }

    // MARK: - ALTER TABLE … RENAME TO

    public func rename(_ to: VirtualTable) -> String {
        rename(to: to)
    }

}

public final class SQLTableBuilder {

    fileprivate var definitions = [SQLExpressible]()

    public func column<V: Value>(_ name: SQLExpression<V>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                 defaultValue: SQLExpression<V>? = nil) {
        column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                 defaultValue: V) {
        column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, unique: Bool = false, check: SQLExpression<Bool?>,
                                 defaultValue: SQLExpression<V>? = nil) {
        column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, unique: Bool = false, check: SQLExpression<Bool?>,
                                 defaultValue: V) {
        column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                 defaultValue: SQLExpression<V>? = nil) {
        column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                 defaultValue: SQLExpression<V?>) {
        column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                 defaultValue: V) {
        column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool?>,
                                 defaultValue: SQLExpression<V>? = nil) {
        column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool?>,
                                 defaultValue: SQLExpression<V?>) {
        column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool?>,
                                 defaultValue: V) {
        column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, primaryKey: Bool, check: SQLExpression<Bool>? = nil,
                                 defaultValue: SQLExpression<V>? = nil) {
        column(name, V.declaredDatatype, primaryKey ? .default : nil, false, false, check, defaultValue, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, primaryKey: Bool, check: SQLExpression<Bool?>,
                                 defaultValue: SQLExpression<V>? = nil) {
        column(name, V.declaredDatatype, primaryKey ? .default : nil, false, false, check, defaultValue, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, primaryKey: PrimaryKey,
                                 check: SQLExpression<Bool>? = nil) where V.Datatype == Int64 {
        column(name, V.declaredDatatype, primaryKey, false, false, check, nil, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, primaryKey: PrimaryKey,
                                 check: SQLExpression<Bool?>) where V.Datatype == Int64 {
        column(name, V.declaredDatatype, primaryKey, false, false, check, nil, nil, nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                 references table: QueryType, _ other: SQLExpression<V>) where V.Datatype == Int64 {
        column(name, V.declaredDatatype, nil, false, unique, check, nil, (table, other), nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, unique: Bool = false, check: SQLExpression<Bool?>,
                                 references table: QueryType, _ other: SQLExpression<V>) where V.Datatype == Int64 {
        column(name, V.declaredDatatype, nil, false, unique, check, nil, (table, other), nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                 references table: QueryType, _ other: SQLExpression<V>) where V.Datatype == Int64 {
        column(name, V.declaredDatatype, nil, true, unique, check, nil, (table, other), nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool?>,
                                 references table: QueryType, _ other: SQLExpression<V>) where V.Datatype == Int64 {
        column(name, V.declaredDatatype, nil, true, unique, check, nil, (table, other), nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, primaryKey: Bool, check: SQLExpression<Bool>? = nil,
                                 references table: QueryType, _ other: SQLExpression<V>) where V.Datatype == Int64 {
        column(name, V.declaredDatatype, primaryKey ? .default : nil, false, false, check, nil, (table, other), nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, primaryKey: Bool, check: SQLExpression<Bool?>,
                                 references table: QueryType, _ other: SQLExpression<V>) where V.Datatype == Int64 {
        column(name, V.declaredDatatype, primaryKey ? .default : nil, false, false, check, nil, (table, other), nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, primaryKey: Bool, check: SQLExpression<Bool>? = nil,
                                 references table: QueryType, _ other: SQLExpression<V>) where V.Datatype == Int64 {
        column(name, V.declaredDatatype, primaryKey ? .default : nil, true, false, check, nil, (table, other), nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, primaryKey: Bool, check: SQLExpression<Bool?>,
                                 references table: QueryType, _ other: SQLExpression<V>) where V.Datatype == Int64 {
        column(name, V.declaredDatatype, primaryKey ? .default : nil, true, false, check, nil, (table, other), nil)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                 defaultValue: SQLExpression<V>? = nil, collate: Collation) where V.Datatype == String {
        column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, collate)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                 defaultValue: V, collate: Collation) where V.Datatype == String {
        column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, collate)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, unique: Bool = false, check: SQLExpression<Bool?>,
                                 defaultValue: SQLExpression<V>? = nil, collate: Collation) where V.Datatype == String {
        column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, collate)
    }

    public func column<V: Value>(_ name: SQLExpression<V>, unique: Bool = false, check: SQLExpression<Bool?>,
                                 defaultValue: V, collate: Collation) where V.Datatype == String {
        column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, collate)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                 defaultValue: SQLExpression<V>? = nil, collate: Collation) where V.Datatype == String {
        column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, collate)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                 defaultValue: SQLExpression<V?>, collate: Collation) where V.Datatype == String {
        column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, collate)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool>? = nil,
                                 defaultValue: V, collate: Collation) where V.Datatype == String {
        column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, collate)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool?>,
                                 defaultValue: SQLExpression<V>? = nil, collate: Collation) where V.Datatype == String {
        column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, collate)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool?>,
                                 defaultValue: SQLExpression<V?>, collate: Collation) where V.Datatype == String {
        column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, collate)
    }

    public func column<V: Value>(_ name: SQLExpression<V?>, unique: Bool = false, check: SQLExpression<Bool?>,
                                 defaultValue: V, collate: Collation) where V.Datatype == String {
        column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, collate)
    }

    // swiftlint:disable:next function_parameter_count
    fileprivate func column(_ name: SQLExpressible, _ datatype: String, _ primaryKey: PrimaryKey?, _ null: Bool,
                            _ unique: Bool, _ check: SQLExpressible?, _ defaultValue: SQLExpressible?,
                            _ references: (QueryType, SQLExpressible)?, _ collate: Collation?) {
        definitions.append(definition(name, datatype, primaryKey, null, unique, check, defaultValue, references, collate))
    }

    // MARK: -

    public func primaryKey<T: Value>(_ column: SQLExpression<T>) {
        primaryKey([column])
    }

    public func primaryKey<T: Value, U: Value>(_ compositeA: SQLExpression<T>,
                                               _ expr: SQLExpression<U>) {
        primaryKey([compositeA, expr])
    }

    public func primaryKey<T: Value, U: Value, V: Value>(_ compositeA: SQLExpression<T>,
                                                         _ expr1: SQLExpression<U>,
                                                         _ expr2: SQLExpression<V>) {
        primaryKey([compositeA, expr1, expr2])
    }

    public func primaryKey<T: Value, U: Value, V: Value, W: Value>(_ compositeA: SQLExpression<T>,
                                                                   _ expr1: SQLExpression<U>,
                                                                   _ expr2: SQLExpression<V>,
                                                                   _ expr3: SQLExpression<W>) {
        primaryKey([compositeA, expr1, expr2, expr3])
    }

    fileprivate func primaryKey(_ composite: [SQLExpressible]) {
        definitions.append("PRIMARY KEY".prefix(composite))
    }

    public func unique(_ columns: SQLExpressible...) {
        unique(columns)
    }

    public func unique(_ columns: [SQLExpressible]) {
        definitions.append("UNIQUE".prefix(columns))
    }

    public func check(_ condition: SQLExpression<Bool>) {
        check(SQLExpression<Bool?>(condition))
    }

    public func check(_ condition: SQLExpression<Bool?>) {
        definitions.append("CHECK".prefix(condition))
    }

    public enum Dependency: String {

        case noAction = "NO ACTION"

        case restrict = "RESTRICT"

        case setNull = "SET NULL"

        case setDefault = "SET DEFAULT"

        case cascade = "CASCADE"

    }

    public func foreignKey<T: Value>(_ column: SQLExpression<T>, references table: QueryType, _ other: SQLExpression<T>,
                                     update: Dependency? = nil, delete: Dependency? = nil) {
        foreignKey(column, (table, other), update, delete)
    }

    public func foreignKey<T: Value>(_ column: SQLExpression<T?>, references table: QueryType, _ other: SQLExpression<T>,
                                     update: Dependency? = nil, delete: Dependency? = nil) {
        foreignKey(column, (table, other), update, delete)
    }

    public func foreignKey<T: Value, U: Value>(_ composite: (SQLExpression<T>, SQLExpression<U>),
                                               references table: QueryType, _ other: (SQLExpression<T>, SQLExpression<U>),
                                               update: Dependency? = nil, delete: Dependency? = nil) {
        let composite = ", ".join([composite.0, composite.1])
        let references = (table, ", ".join([other.0, other.1]))

        foreignKey(composite, references, update, delete)
    }

    public func foreignKey<T: Value, U: Value, V: Value>(_ composite: (SQLExpression<T>, SQLExpression<U>, SQLExpression<V>),
                                                         references table: QueryType,
                                                         _ other: (SQLExpression<T>, SQLExpression<U>, SQLExpression<V>),
                                                         update: Dependency? = nil, delete: Dependency? = nil) {
        let composite = ", ".join([composite.0, composite.1, composite.2])
        let references = (table, ", ".join([other.0, other.1, other.2]))

        foreignKey(composite, references, update, delete)
    }

    fileprivate func foreignKey(_ column: SQLExpressible, _ references: (QueryType, SQLExpressible),
                                _ update: Dependency?, _ delete: Dependency?) {
        let clauses: [SQLExpressible?] = [
            "FOREIGN KEY".prefix(column),
            reference(references),
            update.map { SQLExpression<Void>(literal: "ON UPDATE \($0.rawValue)") },
            delete.map { SQLExpression<Void>(literal: "ON DELETE \($0.rawValue)") }
        ]

        definitions.append(" ".join(clauses.compactMap { $0 }))
    }

}

public enum PrimaryKey {

    case `default`

    case autoincrement

}

public struct Module {

    fileprivate let name: String

    fileprivate let arguments: [SQLExpressible]

    public init(_ name: String, _ arguments: [SQLExpressible]) {
        self.init(name: name.quote(), arguments: arguments)
    }

    init(name: String, arguments: [SQLExpressible]) {
        self.name = name
        self.arguments = arguments
    }

}

extension Module: SQLExpressible {

    public var expression: SQLExpression<Void> {
        name.wrap(arguments)
    }

}

// MARK: - Private

private extension QueryType {

    func create(_ identifier: String, _ name: SQLExpressible, _ modifier: Modifier?, _ ifNotExists: Bool) -> SQLExpressible {
        let clauses: [SQLExpressible?] = [
            SQLExpression<Void>(literal: "CREATE"),
            modifier.map { SQLExpression<Void>(literal: $0.rawValue) },
            SQLExpression<Void>(literal: identifier),
            ifNotExists ? SQLExpression<Void>(literal: "IF NOT EXISTS") : nil,
            name
        ]

        return " ".join(clauses.compactMap { $0 })
    }

    func rename(to: Self) -> String {
        " ".join([
            SQLExpression<Void>(literal: "ALTER TABLE"),
            tableName(),
            SQLExpression<Void>(literal: "RENAME TO"),
            SQLExpression<Void>(to.clauses.from.name)
        ]).asSQL()
    }

    func drop(_ identifier: String, _ name: SQLExpressible, _ ifExists: Bool) -> String {
        let clauses: [SQLExpressible?] = [
            SQLExpression<Void>(literal: "DROP \(identifier)"),
            ifExists ? SQLExpression<Void>(literal: "IF EXISTS") : nil,
            name
        ]

        return " ".join(clauses.compactMap { $0 }).asSQL()
    }

}

// swiftlint:disable:next function_parameter_count
private func definition(_ column: SQLExpressible, _ datatype: String, _ primaryKey: PrimaryKey?, _ null: Bool,
                        _ unique: Bool, _ check: SQLExpressible?, _ defaultValue: SQLExpressible?,
                        _ references: (QueryType, SQLExpressible)?, _ collate: Collation?) -> SQLExpressible {
    let clauses: [SQLExpressible?] = [
        column,
        SQLExpression<Void>(literal: datatype),
        primaryKey.map { SQLExpression<Void>(literal: $0 == .autoincrement ? "PRIMARY KEY AUTOINCREMENT" : "PRIMARY KEY") },
        null ? nil : SQLExpression<Void>(literal: "NOT NULL"),
        unique ? SQLExpression<Void>(literal: "UNIQUE") : nil,
        check.map { " ".join([SQLExpression<Void>(literal: "CHECK"), $0]) },
        defaultValue.map { "DEFAULT".prefix($0) },
        references.map(reference),
        collate.map { " ".join([SQLExpression<Void>(literal: "COLLATE"), $0]) }
    ]

    return " ".join(clauses.compactMap { $0 })
}

private func reference(_ primary: (QueryType, SQLExpressible)) -> SQLExpressible {
    " ".join([
        SQLExpression<Void>(literal: "REFERENCES"),
        primary.0.tableName(qualified: false),
        "".wrap(primary.1) as SQLExpression<Void>
    ])
}

private enum Modifier: String {

    case unique = "UNIQUE"

    case temporary = "TEMPORARY"

}
