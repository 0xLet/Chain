import XCTest
@testable import Chain

final class ChainTests: XCTestCase {
    func testExample() {
        var text = ""
        
        Chain.link(
            { print(0) },
            .link(
                { print(1) },
                .link(
                    { print(3) },
                    .complete {
                        text = "Hello, World!"
                    }
                )
            )
        )
        .run()
        
        XCTAssertEqual(text, "Hello, World!")
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}
