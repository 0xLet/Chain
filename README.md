# Chain

## Example Code
```swift
let output = Chain.link(
            .out { "First" },
            .link( .in {
                print("Value: \($0)")
            }, .multi(
                [
                    .multi([
                        .end,
                        .end,
                        .end
                    ]),
                    .link(.out {
                        "Link"
                    }, .link(
                        .out { "Last" },
                        .complete(.inout { value in
                            guard case .string(let value) = value else {
                                XCTFail()
                                return .void
                            }
                            
                            return  .string("\(value) !!!")
                        })
                    ))
                ]
            ))
        )
        .run(name: "ChainTests-testOutput")
```

## Normal Chain Output
```swift
(lldb) po output
▿ Variable
  ▿ array : 2 elements
    ▿ 0 : Variable
      - string : "First"
    ▿ 1 : Variable
      ▿ array : 2 elements
        - 0 : E.Variable.void
        ▿ 1 : Variable
          ▿ array : 2 elements
            ▿ 0 : Variable
              ▿ array : 3 elements
                ▿ 0 : Variable
                  ▿ array : 1 element
                    - 0 : E.Variable.void
                ▿ 1 : Variable
                  ▿ array : 1 element
                    - 0 : E.Variable.void
                ▿ 2 : Variable
                  ▿ array : 1 element
                    - 0 : E.Variable.void
            ▿ 1 : Variable
              ▿ array : 2 elements
                ▿ 0 : Variable
                  - string : "Link"
                ▿ 1 : Variable
                  ▿ array : 2 elements
                    ▿ 0 : Variable
                      - string : "Last"
                    ▿ 1 : Variable
                      ▿ array : 1 element
                        ▿ 0 : Variable
                          - string : "Last !!!"
```

## Flattened Chain Output
```swift
(lldb) po output.flatten
▿ Variable
  ▿ array : 8 elements
    ▿ 0 : Variable
      - string : "First"
    - 1 : E.Variable.void
    - 2 : E.Variable.void
    - 3 : E.Variable.void
    - 4 : E.Variable.void
    ▿ 5 : Variable
      - string : "Link"
    ▿ 6 : Variable
      - string : "Last"
    ▿ 7 : Variable
      - string : "Last !!!"
```
