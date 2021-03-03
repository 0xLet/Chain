import XCTest
@testable import Chain

final class ChainTests: XCTestCase {
    func testExample() {
        var text = ""
        var isLooping = false
        
        let output = Chain.link(
            .void { print(0) },
            .link(
                .void { print(1) },
                .multi(
                    [
                        .background(
                            .void {
                                print("Loading...")
                                sleep(1)
                                print("Loading Done!")
                                isLooping = false
                            },
                            .complete(
                                .void {
                                    XCTAssertEqual(isLooping, false)
                                }
                            )
                        ),
                        
                        .link(
                            .void {
                                isLooping = true
                                while isLooping { }
                            },
                            .complete(
                                .void {
                                    text = "Hello, World!"
                                }
                            )
                        )
                    ]
                )
            )
        )
        .run(name: "ChainTests-testExample", logging: true)
        
        XCTAssertEqual(text, "Hello, World!")
        
        guard case .array(let values) = output else {
            XCTFail()
            return
        }
        
        XCTAssertNotEqual(values.count, 0)
    }
    
    func testOutput() {
        let output = Chain.link(
            .out { "First" },
            .link(
                .in {
                    print("Value: \($0)")
                },
                .multi(
                    [
                        .multi(
                            [
                                .end,
                                .end,
                                .end
                            ]
                        ),
                        .link(
                            .out {
                                "Link"
                            }, .link(
                                .out { "Last" },
                                .complete(
                                    .inout { value in
                                        guard case .string(let value) = value else {
                                            XCTFail()
                                            return .void
                                        }
                                        
                                        return  .string("\(value) !!!")
                                    }
                                )
                            )
                        )
                    ]
                )
            )
        )
        .run(name: "ChainTests-testOutput", logging: true)
        .flatten
        
        guard case .array(let values) = output else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(values[0], .string("First"))
        XCTAssertEqual(values.last, .string("Last !!!"))
        XCTAssertEqual(values.count, 8)
    }
    
    func testChainStep() {
        let chain = Chain.link(
            .out {
                "First"
            },
            .link(
                .inout {
                    .string("Value: \($0)")
                },
                .end
            )
        )
        
        XCTAssertEqual(chain.run(logging: true).flatten, .array([.string("First"), .string("Value: string(\"First\")"), .void]))
        XCTAssertEqual(chain.runHead(logging: true), .string("First"))
        XCTAssertEqual(chain.dropHead()?.runHead(input: .float(3.14), logging: true), .string("Value: float(3.14)"))
    }
    
    static var allTests = [
        ("testExample", testExample),
        ("testOutput", testOutput),
        ("testChainStep", testChainStep)
    ]
}
