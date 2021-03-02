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
                                sleep(5)
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
        .run(name: "ChainTests-testExample")
        
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
        .run(name: "ChainTests-testOutput", shouldFlattenOutput: true)
        
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
        
        XCTAssertEqual(chain.run().flatten, .array([.string("First"), .string("Value: string(\"First\")"), .void]))
        XCTAssertEqual(chain.step(), .string("First"))
        XCTAssertEqual(chain.dropHead()?.step(withInput: .float(3.14)), .string("Value: float(3.14)"))
    }
    
    static var allTests = [
        ("testExample", testExample),
        ("testOutput", testOutput),
        ("testChainStep", testChainStep)
    ]
}
