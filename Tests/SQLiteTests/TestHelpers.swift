import XCTest
@testable import SQLite

class SQLiteTestCase: XCTestCase {
    private var trace: [String: Int]!
    var db: SQLConnection!
    let users = Table("users")

    override func setUpWithError() throws {
        try super.setUpWithError()
        db = try SQLConnection()
        trace = [String: Int]()

        db.trace { SQL in
            // print("SQL: \(SQL)")
            self.trace[SQL, default: 0] += 1
        }
    }

    func createUsersTable() throws {
        try db.execute("""
            CREATE TABLE users (
                id INTEGER PRIMARY KEY,
                email TEXT NOT NULL UNIQUE,
                age INTEGER,
                salary REAL,
                admin BOOLEAN NOT NULL DEFAULT 0 CHECK (admin IN (0, 1)),
                manager_id INTEGER,
                created_at DATETIME,
                FOREIGN KEY(manager_id) REFERENCES users(id)
            )
            """
        )
    }

    func insertUsers(_ names: String...) throws {
        try insertUsers(names)
    }

    func insertUsers(_ names: [String]) throws {
        for name in names { try insertUser(name) }
    }

    @discardableResult func insertUser(_ name: String, age: Int? = nil, admin: Bool = false) throws -> SQLStatement {
        try db.run("INSERT INTO \"users\" (email, age, admin) values (?, ?, ?)",
                   "\(name)@example.com", age?.datatypeValue, admin.datatypeValue)
    }

    func assertSQL(_ SQL: String, _ executions: Int = 1, _ message: String? = nil, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(
            executions, trace[SQL] ?? 0,
            message ?? SQL,
            file: file, line: line
        )
    }

    func assertSQL(_ SQL: String, _ statement: SQLStatement, _ message: String? = nil, file: StaticString = #file, line: UInt = #line) throws {
        try statement.run()
        assertSQL(SQL, 1, message, file: file, line: line)
        if let count = trace[SQL] { trace[SQL] = count - 1 }
    }

//    func AssertSQL(SQL: String, _ query: Query, _ message: String? = nil, file: String = __FILE__, line: UInt = __LINE__) {
//        for _ in query {}
//        AssertSQL(SQL, 1, message, file: file, line: line)
//        if let count = trace[SQL] { trace[SQL] = count - 1 }
//    }

    func async(expect description: String = "async", timeout: Double = 5, block: (@escaping () -> Void) throws -> Void) throws {
        let expectation = self.expectation(description: description)
        try block({ expectation.fulfill() })
        waitForExpectations(timeout: timeout, handler: nil)
    }

}

let bool = SQLExpression<Bool>("bool")
let boolOptional = SQLExpression<Bool?>("boolOptional")

let data = SQLExpression<Blob>("blob")
let dataOptional = SQLExpression<Blob?>("blobOptional")

let date = SQLExpression<Date>("date")
let dateOptional = SQLExpression<Date?>("dateOptional")

let double = SQLExpression<Double>("double")
let doubleOptional = SQLExpression<Double?>("doubleOptional")

let int = SQLExpression<Int>("int")
let intOptional = SQLExpression<Int?>("intOptional")

let int64 = SQLExpression<Int64>("int64")
let int64Optional = SQLExpression<Int64?>("int64Optional")

let string = SQLExpression<String>("string")
let stringOptional = SQLExpression<String?>("stringOptional")

let uuid = SQLExpression<UUID>("uuid")
let uuidOptional = SQLExpression<UUID?>("uuidOptional")

let testUUIDValue = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!

func assertSQL(_ expression1: @autoclosure () -> String, _ expression2: @autoclosure () -> SQLExpressible,
               file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(expression1(), expression2().asSQL(), file: file, line: line)
}

let table = Table("table")
let qualifiedTable = Table("table", database: "main")
let virtualTable = VirtualTable("virtual_table")
let _view = View("view") // avoid Mac XCTestCase collision

class TestCodable: Codable, Equatable {
    let int: Int
    let string: String
    let bool: Bool
    let float: Float
    let double: Double
    let date: Date
    let uuid: UUID
    let optional: String?
    let sub: TestCodable?

    init(int: Int, string: String, bool: Bool, float: Float, double: Double, date: Date, uuid: UUID, optional: String?, sub: TestCodable?) {
        self.int = int
        self.string = string
        self.bool = bool
        self.float = float
        self.double = double
        self.date = date
        self.uuid = uuid
        self.optional = optional
        self.sub = sub
    }

    static func == (lhs: TestCodable, rhs: TestCodable) -> Bool {
        lhs.int == rhs.int &&
        lhs.string == rhs.string &&
        lhs.bool == rhs.bool &&
        lhs.float == rhs.float &&
        lhs.double == rhs.double &&
        lhs.date == rhs.date &&
        lhs.uuid == lhs.uuid &&
        lhs.optional == rhs.optional &&
        lhs.sub == rhs.sub
    }
}

struct TestOptionalCodable: Codable, Equatable {
    let int: Int?
    let string: String?
    let bool: Bool?
    let float: Float?
    let double: Double?
    let date: Date?
    let uuid: UUID?

    init(int: Int?, string: String?, bool: Bool?, float: Float?, double: Double?, date: Date?, uuid: UUID?) {
        self.int = int
        self.string = string
        self.bool = bool
        self.float = float
        self.double = double
        self.date = date
        self.uuid = uuid
    }
}
