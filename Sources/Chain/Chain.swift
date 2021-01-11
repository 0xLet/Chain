import Foundation

public typealias ChainAction = () -> Void

public indirect enum Chain {
    case end
    case complete(ChainAction?)
    case link(ChainAction, Chain)
    case background(ChainAction, Chain)
    case multi([Chain])
}

public extension Chain {
    func run() {
        switch self {
        case .end:
            print("[\(Date())] Chain: End")
        case .complete(let completion):
            print("[\(Date())] Chain: Complete")
            completion?()
        case .link(let action,
                   let next):
            print("[\(Date())] Chain: Link")
            action()
            next.run()
        case .background(let action,
                         let next):
            print("[\(Date())] Chain: Background")
            DispatchQueue.global().async {
                action()
                DispatchQueue.main.async {
                    next.run()
                }
            }
        case .multi(let links):
            print("[\(Date())] Chain: Multi")
            links.forEach { $0.run() }
        }
    }
}
