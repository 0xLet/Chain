import XCTest
import E
@testable import Chain

final class ChainTests: XCTestCase {
    func testExample() {
        var text = ""
        var isLooping = false
        
        let output = Chain.link(
            .out {
                print(0)
                return 0
            },
            .link(
                .out {
                    print(1)
                    return 1
                },
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
                                .out {
                                    XCTAssertEqual(isLooping, false)
                                    
                                    return .string("Done Loading")
                                }
                            )
                        ),
                        
                        .link(
                            .out {
                                isLooping = true
                                while isLooping { }
                                return .string("Done Looping")
                            },
                            .complete(
                                .out {
                                    text = "Hello, World!"
                                    return "Complete"
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
                            .out { "Link" },
                            .link(
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
    
    func testBackgroundOutput() {
        let chain = Chain.link(
            .out {
                "First"
            },
            .background(
                .inout {
                    sleep(3)
                    return .string("Value: \($0)")
                },
                .complete(
                    .inout {
                        print("HERE: \($0)")
                        return "HERE"
                    }
                )
            )
        )
        
        XCTAssertEqual(chain.run(name: "chain.run", logging: true).flatten, .array([.string("First")]))
        XCTAssertEqual(chain.runHead(name: "chain.runHead", logging: true), .string("First"))
        XCTAssertEqual(chain.dropHead()?.runHead(name: "chain.dropHead()?.runHead", input: .float(3.14), logging: true), .array([]))
        
        sleep(6)
    }
    
    static var allTests = [
        ("testExample", testExample),
        ("testOutput", testOutput),
        ("testChainStep", testChainStep),
        ("testBackgroundOutput", testBackgroundOutput)
    ]
}
