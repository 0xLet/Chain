import XCTest
@testable import Chain

final class ChainTests: XCTestCase {
    func testExample() {
        var text = ""
        var isLooping = false
        
        Chain.link(
            { print(0) },
            .link(
                { print(1) },
                .multi(
                    [
                        .background(
                            {
                                print("Loading...")
                                sleep(5)
                                print("Loading Done!")
                                isLooping = false
                            },
                            .complete {
                            }
                        ),
                        
                        .link(
                            {
                                isLooping = true
                                while isLooping { }
                            },
                            .complete {
                                text = "Hello, World!"
                            }
                        )
                        
                       
                    ]
                )
            )
        )
        .run(name: "ChainTests-testExample")
        
        XCTAssertEqual(text, "Hello, World!")
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}
