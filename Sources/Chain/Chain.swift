import Foundation
import E

public indirect enum Chain {
    case end
    case complete(E.Function?)
    case link(E.Function, Chain)
    case background(E.Function, Chain)
    case multi([Chain])
}

public extension Chain {
    func run(
        name: String? = nil,
        input: Variable? = nil,
        shouldFlattenOutput: Bool = false
    ) -> Variable {
        var logInfo: String {
            "[\(Date())] Chain\(name.map { " (\($0)) "} ?? ""):"
        }
        var output: Variable = .array([])
        
        switch self {
        case .end:
            print("\(logInfo) End")
            
            output = output.update {
                .array($0 + [Variable.void])
            }
        case .complete(let completion):
            print("\(logInfo) Complete")
            
            output = output.update {
                .array($0 + [completion?.run(input) ?? Variable.void])
            }
        case .link(let action,
                   let next):
            print("\(logInfo) Link")
            
            let actionOutput: Variable = action.run(input) ?? Variable.void
            
            output = output.update {
                .array($0 + [actionOutput] + [next.run(name: name, input: actionOutput)])
            }
        case .background(let action,
                         let next):
            print("\(logInfo) Background")
            DispatchQueue.global().async {
                let actionOutput: Variable = action.run(input) ?? Variable.void
                
                output = output.update {
                    .array($0 + [actionOutput])
                }
                DispatchQueue.main.async {
                    output = output.update {
                        .array($0 + [next.run(name: name, input: actionOutput)])
                    }
                }
            }
        case .multi(let links):
            print("\(logInfo) Multi")
            output = output.update {
                .array($0 + links.map { $0.run(name: name) })
            }
        }
        
        // Flatten Output
        if shouldFlattenOutput {
            return output.flatten
        }
        
        return output
    }
}
