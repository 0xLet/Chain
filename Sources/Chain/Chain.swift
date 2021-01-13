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
    func run(name: String? = nil) {
        var logInfo: String {
            "[\(Date())] Chain\(name.map { " (\($0)) "} ?? ""):"
        }
        switch self {
        case .end:
            print("\(logInfo) End")
        case .complete(let completion):
            print("\(logInfo) Complete")
            completion?()
        case .link(let action,
                   let next):
            print("\(logInfo) Link")
            action()
            next.run()
        case .background(let action,
                         let next):
            print("\(logInfo) Background")
            DispatchQueue.global().async {
                action()
                DispatchQueue.main.async {
                    next.run()
                }
            }
        case .multi(let links):
            print("\(logInfo) Multi")
            links.forEach { $0.run() }
        }
    }
}
