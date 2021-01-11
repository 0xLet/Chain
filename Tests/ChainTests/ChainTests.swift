import XCTest
@testable import Chain

final class ChainTests: XCTestCase {
    func testExample() {
        var isLooping = true
        
        var text = ""
        
        
        Chain.link(
            { print(0) },
            .link(
                { print(1) },
                .background(
                    { print(2)
                        sleep(3)
                    },
                    .link(
                        { print(3) },
                          .complete {
                            text = "Hello, World?"
                          }
                    )
                )
            )
        )
        .run()
        
        Chain.background(
            {
                sleep(5)
            },
            .link(
                {
                    XCTAssertEqual(text, "Hello, World!")
                },
                .complete {
                        isLooping = false
                }
            )
        )
        .run()
        
        while isLooping { }
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}
