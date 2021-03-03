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
        logging: Bool = false
    ) -> Variable {
        var output: Variable = .array([])
        
        log(functionName: "run",
            name: name,
            logging: logging)
        
        switch self {
        case .end:
            output = output.update {
                .array($0 + [Variable.void])
            }
        case .complete(let completion):
            output = output.update {
                .array($0 + [completion?.run(input) ?? Variable.void])
            }
        case .link(let action,
                   let next):
            let actionOutput: Variable = action.run(input) ?? Variable.void
            
            output = output.update {
                .array($0 + [actionOutput] + [next.run(name: name,
                                                       input: actionOutput,
                                                       logging: logging)])
            }
        case .background(let action,
                         let next):
            DispatchQueue.global().async {
                let actionOutput: Variable = action.run(input) ?? Variable.void
                
                output = output.update {
                    .array($0 + [actionOutput])
                }
                DispatchQueue.main.async {
                    output = output.update {
                        .array($0 + [next.run(name: name,
                                              input: actionOutput,
                                              logging: logging)])
                    }
                }
            }
        case .multi(let links):
            output = output.update {
                .array($0 + links.map { $0.run(name: name,
                                               logging: logging) })
            }
        }
        
        return output
    }
    
    func runHead(
        name: String? = nil,
        input: Variable? = nil,
        logging: Bool = false
    ) -> Variable {
        log(functionName: "runHead",
            name: name,
            logging: logging)
        
        switch self {
        case .end:
            return .void
        case .complete(let function):
            return function?.run(input) ?? .void
        case .background(let function, _), .link(let function, _):
            return function.run(input) ?? .void
        case .multi(let chains):
            return .array(chains.compactMap { $0.runHead(input: input) })
        }
    }
    
    func dropHead() -> Chain? {
        switch self {
        case .end, .complete(_):
            return nil
        case .background(_, let next), .link(_, let next):
            return next
        case .multi(let chains):
            guard !chains.isEmpty else {
                return nil
            }
            return .multi(chains.compactMap { $0.dropHead() })
        }
    }
}

internal extension Chain {
    func log(
        functionName: String,
        name: String?,
        logging: Bool
    ) {
        var logInfo: String {
            "[\(Date())] Chain.\(functionName)\(name.map { " (\($0)) "} ?? ""):"
        }
        
        if logging {
            switch self {
            case .end:
                print("\(logInfo) End")
            case .complete:
                print("\(logInfo) Complete")
            case .link:
                print("\(logInfo) Link")
            case .background:
                print("\(logInfo) Background")
            case .multi:
                print("\(logInfo) Multi")
            }
        }
    }
}
